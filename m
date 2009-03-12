Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BD7696B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:59:07 -0400 (EDT)
Date: Thu, 12 Mar 2009 19:58:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090312185841.GA27823@random.random>
References: <20090311170611.GA2079@elte.hu> <200903130323.41193.nickpiggin@yahoo.com.au> <20090312170010.GT27823@random.random> <200903130420.28772.nickpiggin@yahoo.com.au> <20090312180648.GV27823@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090312180648.GV27823@random.random>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 07:06:48PM +0100, Andrea Arcangeli wrote:
> again. BTW, I start to think I forgot a tlb flush after setting the
> pte writable again, that could generate a minor fault that we can
> avoid by flushing the tlb, right? But this is a minor thing, and it'd

Ah no, that is already taken care of by the fork flush in the parent
before returning, so no problem (and it would have been a minor thing
anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
