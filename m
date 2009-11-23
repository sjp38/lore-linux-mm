Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BBE896B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 14:31:05 -0500 (EST)
Date: Mon, 23 Nov 2009 13:30:50 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <1259002800.5630.1.camel@penberg-laptop>
Message-ID: <alpine.DEB.2.00.0911231329560.5617@router.home>
References: <20091118181202.GA12180@linux.vnet.ibm.com>  <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>  <1258709153.11284.429.camel@laptop>  <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>  <1258714328.11284.522.camel@laptop>
 <4B067816.6070304@cs.helsinki.fi>  <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <peterz@infradead.org>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Nov 2009, Pekka Enberg wrote:

> That turns out to be _very_ hard. How about something like the following
> untested patch which delays slab_destroy() while we're under nc->lock.

Code changes to deal with a diagnostic issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
