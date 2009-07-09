Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7ECCF6B0055
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 19:15:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n69NZiBW027047
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Jul 2009 08:35:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB08D45DE52
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:35:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 70B6545DE4F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:35:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 567EC1DB803A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:35:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F1E7E1DB803F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:35:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] OOM analysis helper patch series v2
In-Reply-To: <alpine.DEB.1.00.0907091502450.25351@mail.selltech.ca>
References: <alpine.DEB.1.00.0907091038380.22613@mail.selltech.ca> <alpine.DEB.1.00.0907091502450.25351@mail.selltech.ca>
Message-Id: <20090710083407.17BE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Jul 2009 08:35:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 9 Jul 2009, Li, Ming Chun wrote:
> 
> I am applying the patch series to 2.6.31-rc2.

hm, maybe I worked on a bit old tree. I will check latest linus tree again
today.

thanks.


> > ---------------
> > /usr/src/linux-2.6# git checkout experimental
> > Switched to branch "experimental"
> > 
> > /usr/src/linux-2.6# git am ./patches/km1.patch
> > Applying add per-zone statistics to show_free_areas()
> > 
> > /usr/src/linux-2.6# git am ./patches/km2.patch
> > Applying add buffer cache information to show_free_areas()
> > error: patch failed: mm/page_alloc.c:2118
> > error: mm/page_alloc.c: patch does not apply
> > Patch failed at 0002.
> > When you have resolved this problem run "git-am --resolved".
> > If you would prefer to skip this patch, instead run "git-am --skip".
> > 
> > /usr/src/linux-2.6# git am ./patches/km3.patch
> > previous dotest directory .dotest still exists but mbox given.
> > 
> > /usr/src/linux-2.6# rm -rf .dotest/
> > 
> > /usr/src/linux-2.6# git am ./patches/km3.patch
> > Applying Show kernel stack usage to /proc/meminfo and OOM log
> > 
> > /usr/src/linux-2.6# git am ./patches/km4.patch
> > Applying add isolate pages vmstat
> > error: patch failed: mm/page_alloc.c:2115
> > error: mm/page_alloc.c: patch does not apply
> > Patch failed at 0002.
> > When you have resolved this problem run "git-am --resolved".
> > If you would prefer to skip this patch, instead run "git-am --skip".
> > 
> > /usr/src/linux-2.6# git am ./patches/km5.patch
> > previous dotest directory .dotest still exists but mbox given.
> > 
> > /usr/src/linux-2.6# rm -rf .dotest/
> > 
> > /usr/src/linux-2.6# git am ./patches/km5.patch
> > Applying add shmem vmstat
> > error: patch failed: include/linux/mmzone.h:102
> > error: include/linux/mmzone.h: patch does not apply
> > error: patch failed: mm/vmstat.c:646
> > error: mm/vmstat.c: patch does not apply
> > error: patch failed: mm/page_alloc.c:2120
> > error: mm/page_alloc.c: patch does not apply
> > Patch failed at 0002.
> > When you have resolved this problem run "git-am --resolved".
> > If you would prefer to skip this patch, instead run "git-am --skip".
> > ------------
> > 
> > Is there any better way that you could recommend to me to apply your 
> > patches cleanly? Thanks.
> > 
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
