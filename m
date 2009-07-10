Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A335E6B005A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 13:09:41 -0400 (EDT)
Date: Fri, 10 Jul 2009 18:09:35 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
In-Reply-To: <20090710134228.GX356@random.random>
Message-ID: <Pine.LNX.4.64.0907101757590.24800@sister.anvils>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
 <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
 <20090708173206.GN356@random.random> <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
 <20090710134228.GX356@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009, Andrea Arcangeli wrote:
> On Fri, Jul 10, 2009 at 12:18:07PM +0100, Hugh Dickins wrote:
> > as an "automatic" KSM page, I don't know; or we'll need to teach KSM
> > not to waste its time remerging instances of the ZERO_PAGE to a
> > zeroed KSM page.  We'll worry about that once both sets in mmotm.
> 
> There is no risk of collision, zero page is not anonymous so...

You're right, yes, no change required.

> 
> I think it's a mistake for them not to try ksm first regardless of the
> new zeropage patches being floating around, because my whole point is
> that those kind of apps will save more than just zero page with
> ksm. Sure not guaranteed... but possible and worth checking.

Okay, you're right to ask people to give KSM a try: there may be some
apps wanting ZERO_PAGE back, which would really benefit from having
other pages also merged for them, despite the cost.

(And the cost may not be so bad, given that you can stop KSM scanning
for merges, while still keeping all the merges already made.)

But I'm not going to hold my breath on that, and I don't think Kame
should hold back his patch for that.  Particularly since it would
need the extensions to apply KSM to other processes, and we're not
giving those any thought this time around.

(Beyond musing that if we're going to apply madvise MADV_MERGEABLE
to other processes, wouldn't we do better to extend the idea, to be
able to apply madvise and mlock generally to other processes?).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
