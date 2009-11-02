Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0CD9F6B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:25:20 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA27PITO032209
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 16:25:18 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 14BC045DE6F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:25:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E317E45DE60
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:25:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C80111DB803F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:25:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B74C1DB803B
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:25:17 +0900 (JST)
Date: Mon, 2 Nov 2009 16:22:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm][PATCH 0/6] oom-killer: total renewal
Message-Id: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi, as discussed in "Memory overcommit" threads, I started rewrite.

This is just for showing "I started" (not just chating or sleeping ;)

All implemtations are not fixed yet. So feel free to do any comments.
This set is for minimum change set, I think. Some more rich functions
can be implemented based on this.

All patches are against "mm-of-the-moment snapshot 2009-11-01-10-01"

Patches are organized as

(1) pass oom-killer more information, classification and fix mempolicy case.
(2) counting swap usage
(3) counting lowmem usage
(4) fork bomb detector/killer
(5) check expansion of total_vm
(6) rewrite __badness().

passed small tests on x86-64 boxes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
