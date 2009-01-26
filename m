Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59ABA6B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 18:57:30 -0500 (EST)
Date: Tue, 27 Jan 2009 00:57:15 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v2][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20090126235715.GB8726@elte.hu>
References: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com> <20090126113728.58212a30.akpm@linux-foundation.org> <604427e00901261508n7967ea74m3deacd3213c86065@mail.gmail.com> <20090126155246.2d7df309.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090126155246.2d7df309.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mikew@google.com, rientjes@google.com, rohitseth@google.com, hugh@veritas.com, a.p.zijlstra@chello.nl, hpa@zytor.com, edwintorok@gmail.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> I think that a good way to present this is as a preparatory patch: 
> "convert the fourth argument to handle_mm_fault() from a boolean to a 
> flags word".  That would be a simple do-nothing patch which affects all 
> architectures and which ideally would break the build at any unconverted 
> code sites.  (Change the argument order?)

why not do what i suggested: refactor do_page_fault() into a platform 
specific / kernel-internal faults and into a generic-user-pte function. 
That alone would increase readability i suspect.

Then the 'retry' is multiple calls from handle_pte_fault().

Or something like that.

It looks wrong to me to pass another flag through this hot codepath, just 
to express a property that the _highlevel_ code is interested in.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
