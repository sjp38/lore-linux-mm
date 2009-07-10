Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D2C26B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 09:17:44 -0400 (EDT)
Date: Fri, 10 Jul 2009 15:42:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090710134228.GX356@random.random>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
 <20090707084750.GX2714@wotan.suse.de>
 <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
 <20090708173206.GN356@random.random>
 <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 12:18:07PM +0100, Hugh Dickins wrote:
> as an "automatic" KSM page, I don't know; or we'll need to teach KSM
> not to waste its time remerging instances of the ZERO_PAGE to a
> zeroed KSM page.  We'll worry about that once both sets in mmotm.

There is no risk of collision, zero page is not anonymous so...

I think it's a mistake for them not to try ksm first regardless of the
new zeropage patches being floating around, because my whole point is
that those kind of apps will save more than just zero page with
ksm. Sure not guaranteed... but possible and worth checking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
