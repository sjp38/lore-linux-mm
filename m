Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BAA8A6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:31:04 -0400 (EDT)
Received: by bwz21 with SMTP id 21so2480017bwz.38
        for <linux-mm@kvack.org>; Fri, 12 Jun 2009 03:32:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0906121328030.32274@melkki.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
	 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
	 <20090612101511.GC13607@wotan.suse.de>
	 <Pine.LNX.4.64.0906121328030.32274@melkki.cs.Helsinki.FI>
Date: Fri, 12 Jun 2009 13:32:01 +0300
Message-ID: <84144f020906120332q1a09ed14w155719a1107ae373@mail.gmail.com>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 1:30 PM, Pekka J Enberg<penberg@cs.helsinki.fi> wrote:
> Hmm. This is turning into one epic patch discussion for sure! But here's a
> patch to do what you suggested. With the amount of patches I am
> generating, I'm bound to hit the right one sooner or later, no?-)

[ And yes, I do see SLAB parts are not even compiling. But you get the idea. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
