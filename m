Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 84A3F6B00A4
	for <linux-mm@kvack.org>; Sun, 26 Jul 2009 18:56:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6QMuHuo026939
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Jul 2009 07:56:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D1C245DE57
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 07:56:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BFC45DE54
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 07:56:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2D721DB8042
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 07:56:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B32F1DB803E
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 07:56:16 +0900 (JST)
Message-ID: <d3f2ef305f8c04aca0d93765a8dde741.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0907261639570.32238@sister.anvils>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
    <20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
    <20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
    <20090722171245.d5b3a108.akpm@linux-foundation.org>
    <20090723093334.3166e9d2.kamezawa.hiroyu@jp.fujitsu.com>
    <Pine.LNX.4.64.0907261639570.32238@sister.anvils>
Date: Mon, 27 Jul 2009 07:56:15 +0900 (JST)
Subject: Re: [PATCH 0/2] ZERO PAGE again v4.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, avi@redhat.com, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hugh Dickins さんは書きました：
> On Thu, 23 Jul 2009, KAMEZAWA Hiroyuki wrote:
>> On Wed, 22 Jul 2009 17:12:45 -0700
>> Andrew Morton <akpm@linux-foundation.org> wrote:
>> > On Thu, 23 Jul 2009 08:51:37 +0900
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > On Thu, 16 Jul 2009 18:01:34 +0900
>> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > >
>> > > > Rebased onto  mm-of-the-moment snapshot 2009-07-15-20-57.
>> > > > And modifeied to make vm_normal_page() eat FOLL_NOZERO, directly.
>> > > >
>> > > > Any comments ?
>
> Sorry, I've been waiting to have something positive to suggest,
> but today still busy with my own issues (handling OOM in KSM).
>
no problems. thank you.

> I do dislike that additional argument to vm_normal_page, and
> feel that's a problem to be solved in follow_page, rather
> than spread to every other vm_normal_page user.
>
Hmm, I'll check whether it's necessary or not agian before v5.

> Does follow_page even need to be using vm_normal_page?
Avoiding it means follow_page() has to handle pte_special().
But yes, all vm_normal_page() users other than get_user_page() uses
__FOLL_NOZERO. I feel it's just "which is cleaner ?" problem.


> Hmm, VM_MIXEDMAP, __get_user_pages doesn't exclude that.
> > I also feel a strong (but not yet fulfilled) urge to check
> all the use_zero_page ignore_zero stuff: which is far from
> self-evident.
>
I'll add comment more, in v5 (if vm_normal_page() still have "flags")

I myself feels I'll have to update this to v6 or v7.

Thank you
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
