Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8BE616B0055
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:32:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C8Wof1030496
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Mar 2009 17:32:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C309445DE51
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:32:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A1BC345DE4E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:32:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AF96E08006
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:32:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 47B021DB8016
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:32:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
In-Reply-To: <200903112254.56764.nickpiggin@yahoo.com.au>
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com> <200903112254.56764.nickpiggin@yahoo.com.au>
Message-Id: <20090312172619.43BA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Mar 2009 17:32:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Daniel Lowengrub <lowdanie@gmail.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wednesday 11 March 2009 20:55:48 Daniel Lowengrub wrote:
> > Use the linked list defined list.h for the list of vmas that's stored
> > in the mm_struct structure.  Wrapper functions "vma_next" and
> > "vma_prev" are also implemented.  Functions that operate on more than
> > one vma are now given a list of vmas as input.
> 
> I'd love to be able to justify having a doubly linked list for vmas...
> It's easier than managing singly linked lists by hand :) So if you have
> such a good increase with lookups, it might be a good idea. I wouldn't
> like to see vm_area_struct go above 192 bytes on any config if possible
> though.

Currently, sizeof(struct vm_area_struct) on x86_64 is 176.
if we assume 32byte cache-line, 176byte is 6 cache-line.
then, making coubly linked list don't cause d-cache pollution. 

Therefore, We can merge this patch after some cleanups.
(of cource, your opining cleanups is obiously necessary...)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
