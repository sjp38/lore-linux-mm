Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7CA1E6B00BF
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:24:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K3ObgQ020135
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Oct 2010 12:24:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AED745DE61
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:24:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C82545DE69
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:24:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C6791DB803C
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:24:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 119E0E1800F
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:24:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: oom_killer crash linux system
In-Reply-To: <1287543520.2074.1.camel@myhost>
References: <20101020112828.1818.A69D9226@jp.fujitsu.com> <1287543520.2074.1.camel@myhost>
Message-Id: <20101020122137.1824.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 20 Oct 2010 12:24:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> > 
> > can you please try 1) invoke oom 2) get page-types -r again. I'm curious
> > that oom makes page accounting lost again. I mean, please send us oom 
> > log and "page-types -r" result.
> > 
> > thanks
> 
> ok, i do the experiment and catch the log:

thanks.


> active_anon:398375 inactive_anon:82967 isolated_anon:0 
>  active_file:81 inactive_file:429 isolated_file:32
>  unevictable:13 dirty:2 writeback:14 unstable:0
>  free:11942 slab_reclaimable:2391 slab_unreclaimable:3303
>  mapped:5617 shmem:33909 pagetables:2280 bounce:0

active_anon + inactive_anon + isolated_anon = 481342 pages ~= 1.8GB
Um, this oom doesn't makes accounting lost.

> here is the page-types log:
>              flags	page-count       MB  symbolic-flags long-symbolic-flags
> 
> 0x0000000000005828	     83024      324 ___U_l_____Ma_b___________________ uptodate,lru,mmap,anonymous,swapbacked
> 0x0000000000005868	    358737     1401 ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked
>              total	    515071     2011

page-types show similar result.


The big difference is, previous and current are showing some different processes.
only previous has VirtualBox, only current has vmware-usbarbit, etc..

Can you use same test environment?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
