ad_library {

    Procs to set up the dotLRN news aggregator applet

    @author simon@collaboraid.biz
}

namespace eval dotlrn_news_aggregator {}

ad_proc -public dotlrn_news_aggregator::applet_key {} {
    What's my applet key?
} {
    return dotlrn_news_aggregator
}

ad_proc -public dotlrn_news_aggregator::package_key {} {
    What package do I deal with?
} {
    return news-aggregator
}

ad_proc -public dotlrn_news_aggregator::my_package_key {} {
    What package do I deal with?
} {
    return "dotlrn-news-aggregator"
}

ad_proc -public dotlrn_news_aggregator::get_pretty_name {} {
    returns the pretty name
} {
    return "#news-aggregator-portlet.pretty_name#"
}

ad_proc -public dotlrn_news_aggregator::add_applet {} {
    One time init - must be repeatable!
} {
    dotlrn_applet::add_applet_to_dotlrn -applet_key [applet_key] -package_key [my_package_key]
}

ad_proc -public dotlrn_news_aggregator::remove_applet {} {
    One time destroy.
} {
    dotlrn_applet::remove_applet_from_dotlrn -applet_key [applet_key]
}

ad_proc -public dotlrn_news_aggregator::add_applet_to_community {
    community_id
} {
    Add the news-aggregator applet to a specific dotlrn community
} {
    set portal_id [dotlrn_community::get_portal_id -community_id $community_id]

    # create the news-aggregator package instance (all in one, I've mounted it)
    set package_id [dotlrn::instantiate_and_mount $community_id [package_key]]

    # set up the admin portal
    set admin_portal_id [dotlrn_community::get_admin_portal_id \
                             -community_id $community_id
                        ]

    news_aggregator_admin_portlet::add_self_to_page \
        -portal_id $admin_portal_id \
        -package_id $package_id

    set args [ns_set create]
    ns_set put $args package_id $package_id
    add_portlet_helper $portal_id $args

    #create a aggregator to avoid the "no aggregator"-error
    #begin
    set package_name [apm_instance_name_from_id [ad_conn package_id]]
    set aggregator_name "${package_name} - #news-aggregator.pretty_name#"
    set user_id [ad_conn user_id]
    set aggregator_id [news_aggregator::aggregator::new \
                                -aggregator_name $aggregator_name \
                                -package_id $package_id \
                                -public_p 0 \
                                -creation_user $user_id \
                           -creation_ip [ad_conn peeraddr]]
        news_aggregator::aggregator::set_user_default -user_id $user_id \
            -package_id $package_id -aggregator_id $aggregator_id
        #load preinstalled subscriptions into aggregator
        news_aggregator::aggregator::load_preinstalled_subscriptions \
            -aggregator_id $aggregator_id \
            -package_id $package_id
    #end

    return $package_id
}

ad_proc -public dotlrn_news_aggregator::remove_applet_from_community {
    community_id
} {
    Remove the applet from the community.
} {
    ad_return_complaint 1 "[applet_key] remove_applet_from_community not implemented!"
}

ad_proc -public dotlrn_news_aggregator::add_user {
    user_id
} {
    Nothing to do here.
} {
    # noop
}

ad_proc -public dotlrn_news_aggregator::remove_user {
    user_id
} {
    Nothing to do here.
} {
    # noop
}

ad_proc -public dotlrn_news_aggregator::add_user_to_community {
    community_id
    user_id
} {
    Add a user to a specific dotlrn community
} {
    set package_id [dotlrn_community::get_applet_package_id -community_id $community_id -applet_key [applet_key]]
    set portal_id [dotlrn::get_portal_id -user_id $user_id]

    # use "append" here since we want to aggregate
    set args [ns_set create]
    ns_set put $args package_id $package_id
    ns_set put $args param_action append
    add_portlet_helper $portal_id $args
}

ad_proc -public dotlrn_news_aggregator::remove_user_from_community {
    community_id
    user_id
} {
    Remove a user from a community
} {
    set package_id [dotlrn_community::get_applet_package_id -community_id $community_id -applet_key [applet_key]]
    set portal_id [dotlrn::get_portal_id -user_id $user_id]

    set args [ns_set create]
    ns_set put $args package_id $package_id

    remove_portlet $portal_id $args
}

ad_proc -public dotlrn_news_aggregator::add_portlet {
    portal_id
} {
    A helper proc to add the underlying portlet to the given portal.

    @param portal_id
} {
    # simple, no type specific stuff, just set some dummy values

    set args [ns_set create]
    ns_set put $args package_id 0
    ns_set put $args param_action overwrite
    add_portlet_helper $portal_id $args
}

ad_proc -public dotlrn_news_aggregator::add_portlet_helper {
    portal_id
    args
} {
    A helper proc to add the underlying portlet to the given portal.

    @param portal_id
    @param args an ns_set
} {
    news_aggregator_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id [ns_set get $args package_id] \
        -param_action [ns_set get $args param_action]
}

ad_proc -public dotlrn_news_aggregator::remove_portlet {
    portal_id
    args
} {
    A helper proc to remove the underlying portlet from the given portal.

    @param portal_id
    @param args A list of key-value pairs (possibly user_id, community_id, and more)
} {
    news_aggregator_portlet::remove_self_from_page \
        -portal_id $portal_id \
        -package_id [ns_set get $args package_id]
}

ad_proc -public dotlrn_news_aggregator::clone {
    old_community_id
    new_community_id
} {
    Clone this applet's content from the old community to the new one
} {
    ns_log notice "Cloning: [applet_key]"
    set new_package_id [add_applet_to_community $new_community_id]
    set old_package_id [dotlrn_community::get_applet_package_id \
                            -community_id $old_community_id \
                            -applet_key [applet_key]
                       ]

    db_exec_plsql call_news_aggregator_clone {}
    return $new_package_id
}

ad_proc -public dotlrn_news_aggregator::change_event_handler {
    community_id
    event
    old_value
    new_value
} {
    Nothing to do here.
} {
    # Hm. Nothing, it seems
}
