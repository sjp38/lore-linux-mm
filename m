Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C50836B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 03:19:00 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9S7IkoU004231
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:18:46 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9S7G13s1269914
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:16:01 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9S7It67005814
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:18:55 +1100
Date: Wed, 28 Oct 2009 12:48:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: make memcg's file mapped consistent with global
 VM
Message-ID: <20091028071854.GL16378@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091028121619.c094e9c0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091028121619.c094e9c0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-10-28 12:16:19]:

> Based on mmotm-Oct13 + some patches in -mm queue.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> memcg-cleanup-file-mapped-consistent-with-globarl-vm-stat.patch
> 
> In global VM, FILE_MAPPED is used but memcg uses MAPPED_FILE.
> This makes grep difficult. Replace memcg's MAPPED_FILE with FILE_MAPPED
> 
> And in global VM, mapped shared memory is accounted into FILE_MAPPED.
> But memcg doesn't. fix it.

I wanted to explicitly avoid this since I wanted to do an iterative
correct accounting of shared memory. The renaming is fine with me
since we don't break ABI in user space.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
