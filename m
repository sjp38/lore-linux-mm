Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E43396B0047
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 19:37:41 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n160bcxT012255
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Feb 2009 09:37:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A7DD45DE51
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 09:37:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5824245DE4E
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 09:37:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F2BB1DB803A
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 09:37:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2EBA1DB803C
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 09:37:37 +0900 (JST)
Date: Fri, 6 Feb 2009 09:36:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Swap Memory
Message-Id: <20090206093627.a90f23b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <77e5ae570902051240l1c7de8d5jbef5cfe55c156b6c@mail.gmail.com>
References: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
	<Pine.LNX.4.64.0902051802480.1445@blonde.anvils>
	<77e5ae570902051110v65e08d87t885378de659195e3@mail.gmail.com>
	<Pine.LNX.4.64.0902051943360.6349@blonde.anvils>
	<77e5ae570902051240l1c7de8d5jbef5cfe55c156b6c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: William Chan <williamchan@google.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, wchan212@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009 12:40:31 -0800
William Chan <williamchan@google.com> wrote:
> > That could be changed, yes: but would multiply the amount of memory
> > needed for recording pages out of swap.  The present design is to
> > minimize the memory needed by what's out on swap.
> 
> Hopefully there will be less pages in swap than in system memory. If
> this is true - the overhead introduced should be minimal relative to
> the overhead the kernel already has for manging system memory pages.
> 
In my experience, you can't assume that ;)

BTW, if you want to do that, changing device layer is much easier than changing
memory management layer. 

Maybe adding device mapper for good-scheduled-swap(but not Raid0) is enough.
Preparing device-mapper layer which does
  1. It can tie several devices of different size.
  2. It chases each block's usage by some logic (LRU) and do block migration
     if necessary.
  3. priority between devices can be set by dm's user-land tools.

Hmm? But I'm not sure this is worth tring.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
