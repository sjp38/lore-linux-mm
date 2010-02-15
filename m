Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 686EF6B007B
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 20:22:44 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F1MfOc005764
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Feb 2010 10:22:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B627845DD70
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:22:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A86A45DE7A
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:22:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C101DB8047
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:22:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D6CE1DB8044
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:22:39 +0900 (JST)
Date: Mon, 15 Feb 2010 10:19:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.31 and OOM killer = bug?
Message-Id: <20100215101917.15552a51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <E0975165-4185-47A9-A15F-B46774A5F6DA@gmail.com>
References: <E0975165-4185-47A9-A15F-B46774A5F6DA@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anton Starikov <ant.starikov@gmail.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 00:43:02 +0100
Anton Starikov <ant.starikov@gmail.com> wrote:

> Hi,
> 
> The setup:
> is 16-core opteron node, diskless with NFS root, swapless, 64GB of RAM. Operating under OpenSUSE 11.2. With kernel version 2.6.31. Although it isn't vanilla, I think probably more right is to submit this into LKML.
> 

At first, what is the version of kernel you are comparing with ? 2.6.22?(If OpenSuse10)
If so, many changes since that..

> The problem:
> On this node user run MPI job with 16 processes, local job by using shared memory communication.  
> At some point this processes are trying to use more memory that available.
> Normally, all of them or part of them would be killed by OOM killer, and it use to work for years over many versions of kernel.
> 
> Now, with fresh setup I got something new. OOM tried to kill, but didn't succeed, and even more, brought system in unusable state. All those processes are locked and un-killable. some of other processes are also locked and un-killable/inaccessible. kswapd consume 100% CPU (which I think is expected behavior when there is no free memory). 
> No free memory obviously, cause all original processes are still in memory.
> 
> I tried to test OOM behavior and it always happens like that now.
> 
> Here I attach full gzipped log of all related information captured by logserver (sent by logserver and netconsole, so it can be partly doubled). Sorry that it is too big, but I didn't know what information can be important.
> 

Anyway, I think it's not appreciated to depend on OOM-Kill on swapless-system.
I recommend you to use cgroup "memory" to encapsulate your apps (but please check
the performance regression can be seen or not..)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
