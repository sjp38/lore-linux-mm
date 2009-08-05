Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D653B6B0082
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 06:18:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n75AIWj2025524
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Aug 2009 19:18:32 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8625745DE51
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:18:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6577245DE4E
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:18:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E38B1DB803F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:18:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3CAC1DB803C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:18:31 +0900 (JST)
Date: Wed, 5 Aug 2009 19:16:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] ZERO_PAGE again v5.
Message-Id: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, hugh.dickins@tiscali.co.uk, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


Updated from v4 as
  - avoid to add new arguments to vm_normal_page().
    vm_normal_page() always returns NULL if ZERO_PAGE is found.
  - follow_page() directly handles pte_special and ANON_ZERO_PAGE.

Then, amount of changes are reduced. Thanks for advices.

Concerns pointed out:
  - Does use_zero_page() cover all cases ?
    I think yes..
  - All get_user_pages() callers, which may find ZERO_PAGE is safe ?
    need tests.
  - All follow_pages() callers, which may find ZERO_PAGE is safe ?
    I think yes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
