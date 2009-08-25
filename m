Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E88046B0089
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:43:08 -0400 (EDT)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P9e4Dp024721
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 18:40:04 +0900
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P9dSv4024562
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 18:39:29 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E4EA45DE50
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:39:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E84E245DE4E
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:39:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D33491DB8038
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:39:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C9F6E08004
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:39:27 +0900 (JST)
Date: Tue, 25 Aug 2009 18:37:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
Message-Id: <20090825183734.1b2d0559.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0908250947400.2872@sister.anvils>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
	<28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
	<20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0908232113w71676aatf22eb6d431501fd0@mail.gmail.com>
	<82e12e5f0908242146uad0f314hcbb02fcc999a1d32@mail.gmail.com>
	<Pine.LNX.4.64.0908250947400.2872@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Hiroaki Wakabayashi <primulaelatior@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009 10:03:30 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> My advice (but I sure hate giving advice before I've tried it myself)
> is to put __mlock_vma_pages_range() back to handling just the mlock
> case, and do your own follow_page() loop in munlock_vma_pages_range().
> 

I have no objections to make use of follow_page().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
