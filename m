Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EFC756B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:27:32 -0400 (EDT)
Date: Thu, 9 Jul 2009 15:05:31 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Re: [PATCH 0/5] OOM analysis helper patch series v2
In-Reply-To: <alpine.DEB.1.00.0907091038380.22613@mail.selltech.ca>
Message-ID: <alpine.DEB.1.00.0907091502450.25351@mail.selltech.ca>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <alpine.DEB.1.00.0907091038380.22613@mail.selltech.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 2009, Li, Ming Chun wrote:

I am applying the patch series to 2.6.31-rc2.

Vincent

> On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:
> 
> > 
> > ChangeLog
> >  Since v1
> >    - Droped "[5/5] add NR_ANON_PAGES to OOM log" patch
> >    - Instead, introduce "[5/5] add shmem vmstat" patch
> >    - Fixed unit bug (Thanks Minchan)
> >    - Separated isolated vmstat to two field (Thanks Minchan and Wu)
> >    - Fixed isolated page and lumpy reclaim issue (Thanks Minchan)
> >    - Rewrote some patch description (Thanks Christoph)
> > 
> > 
> > Current OOM log doesn't provide sufficient memory usage information. it cause
> > make confusion to lkml MM guys. 
> > 
> > this patch series add some memory usage information to OOM log.
> > 
> 
> Hi Kosaki,
> 
> Sorry this is slightly off topic, I am newbie and want to test out your 
> patch series. I am using alpine as email client to save your patches to
> /usr/src/linux-2.6/patches:
> 
> #ls -l /usr/src/linux-2.6/patches/
> 
> -rw------- 1 root src  6682 2009-07-09 10:24 km1.patch
> -rw------- 1 root src  6980 2009-07-09 10:24 km2.patch
> -rw------- 1 root src  9871 2009-07-09 10:24 km3.patch
> -rw------- 1 root src 12539 2009-07-09 10:24 km4.patch
> -rw------- 1 root src 11499 2009-07-09 10:24 km5.patch
> 
> Then I apply your patches using git-am, I got:
> 
> ---------------
> /usr/src/linux-2.6# git checkout experimental
> Switched to branch "experimental"
> 
> /usr/src/linux-2.6# git am ./patches/km1.patch
> Applying add per-zone statistics to show_free_areas()
> 
> /usr/src/linux-2.6# git am ./patches/km2.patch
> Applying add buffer cache information to show_free_areas()
> error: patch failed: mm/page_alloc.c:2118
> error: mm/page_alloc.c: patch does not apply
> Patch failed at 0002.
> When you have resolved this problem run "git-am --resolved".
> If you would prefer to skip this patch, instead run "git-am --skip".
> 
> /usr/src/linux-2.6# git am ./patches/km3.patch
> previous dotest directory .dotest still exists but mbox given.
> 
> /usr/src/linux-2.6# rm -rf .dotest/
> 
> /usr/src/linux-2.6# git am ./patches/km3.patch
> Applying Show kernel stack usage to /proc/meminfo and OOM log
> 
> /usr/src/linux-2.6# git am ./patches/km4.patch
> Applying add isolate pages vmstat
> error: patch failed: mm/page_alloc.c:2115
> error: mm/page_alloc.c: patch does not apply
> Patch failed at 0002.
> When you have resolved this problem run "git-am --resolved".
> If you would prefer to skip this patch, instead run "git-am --skip".
> 
> /usr/src/linux-2.6# git am ./patches/km5.patch
> previous dotest directory .dotest still exists but mbox given.
> 
> /usr/src/linux-2.6# rm -rf .dotest/
> 
> /usr/src/linux-2.6# git am ./patches/km5.patch
> Applying add shmem vmstat
> error: patch failed: include/linux/mmzone.h:102
> error: include/linux/mmzone.h: patch does not apply
> error: patch failed: mm/vmstat.c:646
> error: mm/vmstat.c: patch does not apply
> error: patch failed: mm/page_alloc.c:2120
> error: mm/page_alloc.c: patch does not apply
> Patch failed at 0002.
> When you have resolved this problem run "git-am --resolved".
> If you would prefer to skip this patch, instead run "git-am --skip".
> ------------
> 
> Is there any better way that you could recommend to me to apply your 
> patches cleanly? Thanks.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
