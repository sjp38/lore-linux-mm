Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD8E6B005A
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 08:58:20 -0400 (EDT)
Date: Mon, 15 Jun 2009 14:00:19 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615140019.4e405d37@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.64.0906151341160.25162@sister.anvils>
References: <20090615024520.786814520@intel.com>
	<4A35BD7A.9070208@linux.vnet.ibm.com>
	<20090615042753.GA20788@localhost>
	<Pine.LNX.4.64.0906151341160.25162@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> My opinion is that it's way too late for .31 - your only chance
> is that Linus sometimes gets bored with playing safe, and decides
> to break his rules and try something out regardless - but I'd hope
> the bootmem business already sated his appetite for danger this time.

I see no consensus on it being worth merging, no testing, no upstream
integration shakedown, no builds on non-x86 boxes, no work with other
arch maintainers who have similar abilities and needs.

It belongs in next for a release or two while people work on it, while
things like PPC64 can plumb into it if they wish and while people work
out if its actually useful given that for most users it reduces the
reliability of the services they are providing rather than improving it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
