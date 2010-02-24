Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 782C26B007B
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 21:02:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O1uf5A031594
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 10:56:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EA50845DE50
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:56:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6FFE45DE4D
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:56:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B32311DB8047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:56:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1722B1DB8044
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:56:37 +0900 (JST)
Date: Wed, 24 Feb 2010 10:53:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: way to allocate memory within a range ?
Message-Id: <20100224105312.12847047.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com>
References: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Auguste Mome <augustmome@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Feb 2010 01:46:49 +0100
Auguste Mome <augustmome@gmail.com> wrote:

> Hello,
> I'd like to use kmem_cache() system, but need the memory taken from a
> specific range if requested, outside the range otherwise.
> I think about adding new zone and define new GFP flag to either select or
> ignore the zone. Does it sound possible? Then I welcome any hint if you know
> where to add the appropriated test in allocator, how to attach the
> region to the new zone id).
> 
> Or slab/slub system is not designed for this, I should forget it and
> opt for another system?
> 
I think you can find adding a new zone is very hard.
please forget.

But for what purpose you want to specifiy phyiscal address of memory ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
