Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 28CD16B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 08:55:29 -0400 (EDT)
Date: Tue, 30 Jul 2013 14:55:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130730125525.GB15847@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <20130730074531.GA10584@dhcp22.suse.cz>
 <20130730012544.2f33ebf6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730012544.2f33ebf6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue 30-07-13 01:25:44, Andrew Morton wrote:
> On Tue, 30 Jul 2013 09:45:31 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 29-07-13 13:57:43, Andrew Morton wrote:
> > > On Fri, 26 Jul 2013 14:44:29 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> > [...]
> > > > --- a/fs/drop_caches.c
> > > > +++ b/fs/drop_caches.c
> > > > @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> > > >  	if (ret)
> > > >  		return ret;
> > > >  	if (write) {
> > > > +		printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> > > > +		       current->comm, task_pid_nr(current), sysctl_drop_caches);
> > > >  		if (sysctl_drop_caches & 1)
> > > >  			iterate_supers(drop_pagecache_sb, NULL);
> > > >  		if (sysctl_drop_caches & 2)
> > > 
> > > How about we do
> > > 
> > > 	if (!(sysctl_drop_caches & 4))
> > > 		printk(....)
> > >
> > > so people can turn it off if it's causing problems?
> > 
> > I am OK with that  but can we use a top bit instead. Maybe we never have
> > other entities to drop in the future but it would be better to have a room for them
> > just in case.
> 
> If we add another flag in the future it can use bit 3?

What if we get crazy and need more of them?

> > So what about using 1<<31 instead?
> 
> Could, but negative (or is it positive?) numbers are a bit of a pain.

Yes, that was the point ;), I would like to make a new usage a dance on
the meadows.
But I do not care much, let's use 1<<30 if negative sounds too bad but I
would leave some room for further entities.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
