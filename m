Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E2DF6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:07:09 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6AFWZMx027496
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 11 Jul 2009 00:32:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CEB4445DE51
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 00:32:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 97EE245DE4C
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 00:32:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AA72E08005
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 00:32:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C049B1DB8037
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 00:32:33 +0900 (JST)
Message-ID: <f0e030b8e1a365d1df9197ad7399bdb6.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090710151610.GB356@random.random>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
    <20090707084750.GX2714@wotan.suse.de>
    <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
    <20090708173206.GN356@random.random>
    <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
    <20090710134228.GX356@random.random>
    <9f3ffbd617047982a7aed71548a34f13.squirrel@webmail-b.css.fujitsu.com>
    <20090710151610.GB356@random.random>
Date: Sat, 11 Jul 2009 00:32:33 +0900 (JST)
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Fri, Jul 10, 2009 at 11:12:38PM +0900, KAMEZAWA Hiroyuki wrote:
>> BTW, ksm has no refcnt pingpong problem ?
>
> Well sure it has, the refcount has to be increased when pages are
> shared, just like for regular fork() on anonymous memory, but the
> point is that you pay for it only when you're saving ram, so the
> probability that is just pure overhead is lower than for the zero
> page... it always depend on the app. I simply suggest in trying
> it... perhaps zero page is way to go for your users.. they should
> tell, not us...
>
My point is that we don't have to say "Unless you evolve yourself,
you'll die" to users. they will evolve by themselves if they are sane.
As I said, I like ksm. But demanding users to rewrite private apps is
different problem. I'd like to say "You can live as you're. but here,
there is better options" rather than "die!".
Adding documentation/advertisement and show pros. and cons. of ksm or
something correct is what we can do for increasing sane users.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
