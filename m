Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 5EDAF6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 23:17:58 -0400 (EDT)
Date: Wed, 31 Jul 2013 20:17:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-Id: <20130731201708.efa5ae87.akpm@linux-foundation.org>
In-Reply-To: <51F9D1F6.4080001@jp.fujitsu.com>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
	<20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
	<51F9D1F6.4080001@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, dave@linux.vnet.ibm.com

On Wed, 31 Jul 2013 23:11:50 -0400 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> >> --- a/fs/drop_caches.c
> >> +++ b/fs/drop_caches.c
> >> @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> >>  	if (ret)
> >>  		return ret;
> >>  	if (write) {
> >> +		printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> >> +		       current->comm, task_pid_nr(current), sysctl_drop_caches);
> >>  		if (sysctl_drop_caches & 1)
> >>  			iterate_supers(drop_pagecache_sb, NULL);
> >>  		if (sysctl_drop_caches & 2)
> > 
> > How about we do
> > 
> > 	if (!(sysctl_drop_caches & 4))
> > 		printk(....)
> > 
> > so people can turn it off if it's causing problems?
> 
> The best interface depends on the purpose. If you want to detect crazy application,
> we can't assume an application co-operate us. So, I doubt this works.

You missed the "!".  I'm proposing that setting the new bit 2 will
permit people to prevent the new printk if it is causing them problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
