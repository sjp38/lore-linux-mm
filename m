Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E6F656B0130
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 19:53:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6MNrPGj015527
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Jul 2009 08:53:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AB79445DE57
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:53:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8882845DE55
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:53:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 65B58E08003
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:53:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 017441DB803E
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:53:24 +0900 (JST)
Date: Thu, 23 Jul 2009 08:51:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] ZERO PAGE again v4.
Message-Id: <20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
	<20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009 18:01:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> Rebased onto  mm-of-the-moment snapshot 2009-07-15-20-57.
> And modifeied to make vm_normal_page() eat FOLL_NOZERO, directly.
> 
> Any comments ?
> 

A week passed since I posted this. It's no problem to keep updating this
and post again. But if anyone have concerns, please notify me.
I'll reduce CC: list in the next post.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
