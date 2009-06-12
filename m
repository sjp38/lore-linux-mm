Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AECB56B0092
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:29:28 -0400 (EDT)
Date: Fri, 12 Jun 2009 08:30:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
Message-Id: <20090612083005.56336219.akpm@linux-foundation.org>
In-Reply-To: <1244806440.30512.51.camel@penberg-laptop>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	<Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	<20090612091002.GA32052@elte.hu>
	<84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	<20090612100756.GA25185@elte.hu>
	<84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
	<1244805060.7172.126.camel@pasglop>
	<1244806440.30512.51.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009 14:34:00 +0300 Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> +static gfp_t slab_gfp_mask __read_mostly = __GFP_BITS_MASK & ~__GFP_WAIT;

It'd be safer and saner to disable __GFP_FS and __GFP_IO as well. 
Having either of those flags set without __GFP_WAIT is a somewhat
self-contradictory thing and there might be code under reclaim which
assumes that __GFP_FS|__GFP_IO implies __GFP_WAIT.

<wonders why mempool_alloc() didn't clear __GFP_FS>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
