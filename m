Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 045F26B022D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 19:41:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2TNfMFd007982
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Mar 2010 08:41:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EEE9C45DE51
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 08:41:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CAD4845DE3E
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 08:41:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B132C1DB8041
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 08:41:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FF511DB8042
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 08:41:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect nodes
In-Reply-To: <1269876708.13829.30.camel@useless.americas.hpqcorp.net>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com> <1269876708.13829.30.camel@useless.americas.hpqcorp.net>
Message-Id: <20100330083638.8E87.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Mar 2010 08:41:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, cl@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, minchar.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> I believe that the current code matches the intended semantics.  I can't
> find a man pages for the migrate_pages() system call, but the
> migratepages(8) man page says:
> 
> "If  multiple  nodes  are specified for from-nodes or to-nodes then an
> attempt is made to preserve the relative location of each page in each
> nodeset."

Offtopic>
Christoph, Why migrate_pages(2) doesn't have man pages? Is it unrecommended
syscall?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
