Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 341396B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 04:26:21 -0400 (EDT)
Date: Tue, 30 Jul 2013 01:25:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-Id: <20130730012544.2f33ebf6.akpm@linux-foundation.org>
In-Reply-To: <20130730074531.GA10584@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
	<20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
	<20130730074531.GA10584@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue, 30 Jul 2013 09:45:31 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 29-07-13 13:57:43, Andrew Morton wrote:
> > On Fri, 26 Jul 2013 14:44:29 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > --- a/fs/drop_caches.c
> > > +++ b/fs/drop_caches.c
> > > @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> > >  	if (ret)
> > >  		return ret;
> > >  	if (write) {
> > > +		printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> > > +		       current->comm, task_pid_nr(current), sysctl_drop_caches);
> > >  		if (sysctl_drop_caches & 1)
> > >  			iterate_supers(drop_pagecache_sb, NULL);
> > >  		if (sysctl_drop_caches & 2)
> > 
> > How about we do
> > 
> > 	if (!(sysctl_drop_caches & 4))
> > 		printk(....)
> >
> > so people can turn it off if it's causing problems?
> 
> I am OK with that  but can we use a top bit instead. Maybe we never have
> other entities to drop in the future but it would be better to have a room for them
> just in case.

If we add another flag in the future it can use bit 3?

> So what about using 1<<31 instead?

Could, but negative (or is it positive?) numbers are a bit of a pain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
