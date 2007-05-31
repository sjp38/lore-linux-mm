Subject: Re: [PATCH] Make dynamic/run-time configuration of zonelist order
	configurable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070531213420.7ab44ebf.kamezawa.hiroyu@jp.fujitsu.com>
References: <1180468121.5067.64.camel@localhost>
	 <20070530112119.efa977fe.kamezawa.hiroyu@jp.fujitsu.com>
	 <1180540321.5850.6.camel@localhost>
	 <20070531213420.7ab44ebf.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 13:08:05 -0400
Message-Id: <1180631285.5091.59.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-31 at 21:34 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 30 May 2007 11:52:01 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > On Wed, 2007-05-30 at 11:21 +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 29 May 2007 15:48:41 -0400
> > > Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > > 
> > > > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > > 
> > > 
> > > no problem was found on my ia64 test box.
> > > 
> > > But one point..
> > > 
> > > > -#ifdef CONFIG_NUMA
> > > > +#ifdef CONFIG_DYNAMIC_ZONELIST_ORDER
> > > >  	{
> > > >  		.ctl_name	= CTL_UNNUMBERED,
> > > >  		.procname	= "numa_zonelist_order",
> > > 
> > > non-NUMA, memory-hotpluggable machine need this control ??
> > > 
> > 
> > Hi, Kame:
> > 
> > Here was my thinking on that point--actually on the numa_zonelist_order
> > sysctl in general:
> > 
> > When would it ever be needed?  I think the answer is when the dynamic
> > configuration didn't "get it right" and you want to fix it w/o reboot.
> > I agree that it is very likely that you wouldn't want to reboot if
> > you've gone to all the trouble to support memory hotplug.  In that case,
> > we have a couple of choices:
> > 
> > 1) just enable the config option manually for platforms that support
> > memory hotplug, or
> > 
> > 2) make the option default to 'y' when memory hotplug is configured.
> > 
> > As I tried to indicate in the patch description, because some smallish
> > systems appear to use NUMA emulation for resource management, they must
> > enable NUMA support.  However, they may not [I think probably not] need
> > run-time zoneorder configuration.  I suspect those platforms don't
> > support memory hotplug at this time either.  Now, the code in question
> > [sysctl and build_zonelist functions] may be relatively small--i.e.,
> > less than a page.  But, it all adds up, so I offered a way for small
> > systems that still wanted NUMA support to get back what we took from
> > them with the zonelist order patches.
> > 
> Ah....I know your purpose. What I wanted to say is memory hotplug itseld doesn't need
> "manual" zonelist ordering reconfiguration....it calls build_all_zonelists() in automatic way.
> Then #ifdef around this sysctl should be CONFIG_NUMA && CONFIG_DYNAMIC_ZONELIST_ORDER.

Since CONFIG_DYNAMIC_ZONELIST_ORDER depends on CONFIG_NUMA in my patch,
I didn't think the && was necessary.  

> 
> I know your point and benefits of this patch...(we can remove __init functions if we don't
> use it and reduce memory usage to some extent.)
> To be honest, I myself doesn't like addling new complicated __init thing. 
> But I have no concern if maintainers say ok.

Well, if Andrew doesn't think it's worth it, I'll drop it.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
