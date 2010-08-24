Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CCD5D6008D8
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 03:40:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O7ebP1004955
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 16:40:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 276BE45DE50
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:40:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07F6845DE4E
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:40:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E61EC1DB804E
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:40:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FA431DB8044
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:40:36 +0900 (JST)
Date: Tue, 24 Aug 2010 16:35:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/6] mm: stack based kmap_atomic
Message-Id: <20100824163545.052e44fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100824162427.58e2eb88.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100819201317.673172547@chello.nl>
	<20100819202753.656285068@chello.nl>
	<20100824162427.58e2eb88.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 16:24:27 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> And Is it documented that kmap_atomic shouln't be used under NMI or something
> special interrupts ?
> 
Sorry, I missed something..Maybe not trouble.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
