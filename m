Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AF6226B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 03:54:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o697s9Wk020207
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Jul 2010 16:54:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B37A245DE50
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 16:54:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 929A845DE4E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 16:54:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7963B1DB803E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 16:54:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 21E3A1DB803B
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 16:54:09 +0900 (JST)
Date: Fri, 9 Jul 2010 16:49:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Need some help in understanding sparsemem.
Message-Id: <20100709164932.5e5fd045.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTil7X11whzqzsTudHQNCuFJKprTsStHVQNRgbYZD@mail.gmail.com>
References: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
	<AANLkTik9TlLYbG4GE6TV1wF7SOXz7v7gQ1BR531HGyNx@mail.gmail.com>
	<AANLkTin8JIdtSFR-E1J8FwVR2WTivShmZrEoeJWjCd1j@mail.gmail.com>
	<AANLkTim9d3x8oMLxRLyb2EeKCAxFgsOgw2ip87LUOn7z@mail.gmail.com>
	<AANLkTil7X11whzqzsTudHQNCuFJKprTsStHVQNRgbYZD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: naren.mehra@gmail.com
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2010 12:35:17 +0530
naren.mehra@gmail.com wrote:

> Thanks to you guys, I am now getting a grip on the sparsemem code.
> While going through the code, I came across several instances of the following:
> #ifndef CONFIG_NEED_MULTIPLE_NODES
> .
> <some code>
> .
> #endif
> 
> Now, it seems like this configuration option is used in case there are
> multiple nodes in a system.
> But its linked/depends on NUMA/discontigmem.
> 
> It could be possible that we have multiple nodes in a UMA system.
> How can sparsemem handle such cases ??
> 

sparsemem can be used both in UMA/NUMA case. IOW, sparsemem is for handling
memmap(array of struct page) for flexible memory layout, and not for NUMA.
Then, NUMA/MULTIPLENODE and SPARSEMEM has no relationship, basically.
"nid" is recorded just for detecting the nearest node for allocating mem_map.
(And some 32bit arch recoreds some information of 'nid'.)

So, you shouldn't be suffer from an illusion of sparsemem when you think about
NUMA/MULTIPLENODE. please visit free_area_init_nodes(), and add_active_range(),
remove_actitve_range(). They are for MULTIPLENODES.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
