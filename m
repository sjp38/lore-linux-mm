Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1CEAF6B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 03:27:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S7RPu7001147
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 16:27:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C55445DE4F
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:27:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4788B45DE58
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:27:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BB391DB8045
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:27:25 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BEEEE1DB8042
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:27:24 +0900 (JST)
Date: Wed, 28 Oct 2009 16:24:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: make memcg's file mapped consistent with global
 VM
Message-Id: <20091028162458.45865281.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091028071854.GL16378@balbir.in.ibm.com>
References: <20091028121619.c094e9c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20091028071854.GL16378@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009 12:48:54 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-10-28 12:16:19]:
> 
> > Based on mmotm-Oct13 + some patches in -mm queue.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > memcg-cleanup-file-mapped-consistent-with-globarl-vm-stat.patch
> > 
> > In global VM, FILE_MAPPED is used but memcg uses MAPPED_FILE.
> > This makes grep difficult. Replace memcg's MAPPED_FILE with FILE_MAPPED
> > 
> > And in global VM, mapped shared memory is accounted into FILE_MAPPED.
> > But memcg doesn't. fix it.
> 
> I wanted to explicitly avoid this since I wanted to do an iterative
> correct accounting of shared memory. The renaming is fine with me
> since we don't break ABI in user space.
> 
To do that, FILE_MAPPED is not correct.
Because MAPPED includes shmem in global VM, no valid reason to do different
style of counting.

For shmem, we have a charge type as MEM_CGROUP_CHARGE_TYPE_SHMEM and 
we can set "PCG_SHMEM" flag onto page_cgroup or some.
Then, we can count it in explicit way. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
