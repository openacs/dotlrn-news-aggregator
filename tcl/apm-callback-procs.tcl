ad_library {
    Procedures for registering implementations for the
    dotlrn nwes-aggregator package.

    @creation-date 8 May 2003
    @author Simon Carstensen (simon@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval dotlrn_news_aggregator {}

ad_proc -private dotlrn_news_aggregator::install {} {
    dotLRN Weblogger package install proc
} {
    register_portal_datasource_impl
}

ad_proc -private dotlrn_news_aggregator::uninstall {} {
    dotLRN Weblogger package uninstall proc
} {
    unregister_portal_datasource_impl
}

ad_proc -private dotlrn_news_aggregator::register_portal_datasource_impl {} {
    Register the service contract implementation for the dotlrn_applet service contract
} {
    set spec {
        name "dotlrn_news_aggregator"
	contract_name "dotlrn_applet"
	owner "dotlrn-weblogger"
        aliases {
	    GetPrettyName dotlrn_news_aggregator::get_pretty_name
	    AddApplet dotlrn_news_aggregator::add_applet
	    RemoveApplet dotlrn_news_aggregator::remove_applet
	    AddAppletToCommunity dotlrn_news_aggregator::add_applet_to_community
	    RemoveAppletFromCommunity dotlrn_news_aggregator::remove_applet_from_community
	    AddUser dotlrn_news_aggregator::add_user
	    RemoveUser dotlrn_news_aggregator::remove_user
	    AddUserToCommunity dotlrn_news_aggregator::add_user_to_community
	    RemoveUserFromCommunity dotlrn_news_aggregator::remove_user_from_community
	    AddPortlet dotlrn_news_aggregator::add_portlet
	    RemovePortlet dotlrn_news_aggregator::remove_portlet
	    Clone dotlrn_news_aggregator::clone
	    ChangeEventHandler dotlrn_news_aggregator::change_event_handler
        }
    }

    acs_sc::impl::new_from_spec -spec $spec
}

ad_proc -private dotlrn_news_aggregator::unregister_portal_datasource_impl {} {
    Unregister service contract implementations
} {
    acs_sc::impl::delete \
        -contract_name "dotlrn_applet" \
        -impl_name "dotlrn_news_aggregator"
}
