Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 84C1C6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 09:47:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6AECeO7024904
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 23:12:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5387A45DE50
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:12:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3036645DE4F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:12:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA6331DB803F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:12:39 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A2DCC1DB803E
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:12:39 +0900 (JST)
Message-ID: <9f3ffbd617047982a7aed71548a34f13.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090710134228.GX356@random.random>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
    <20090707084750.GX2714@wotan.suse.de>
    <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
    <20090708173206.GN356@random.random>
    <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
    <20090710134228.GX356@random.random>
Date: Fri, 10 Jul 2009 23:12:38 +0900 (JST)
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli さんは書きました：
> On Fri, Jul 10, 2009 at 12:18:07PM +0100, Hugh Dickins wrote:
>> as an "automatic" KSM page, I don't know; or we'll need to teach KSM
>> not to waste its time remerging instances of the ZERO_PAGE to a
>> zeroed KSM page.  We'll worry about that once both sets in mmotm.
>
> There is no risk of collision, zero page is not anonymous so...
>
> I think it's a mistake for them not to try ksm first regardless of the
> new zeropage patches being floating around, because my whole point is
> that those kind of apps will save more than just zero page with
> ksm. Sure not guaranteed... but possible and worth checking.
>
How many mercyless teachers who know waht is correct there are...

BTW, ksm has no refcnt pingpong problem ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
