Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 938DA8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:57:45 -0400 (EDT)
Subject: Re: [PATCH 0/8] mm/slub: Add SLUB_RANDOMIZE support
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110316022804.27676.qmail@science.horizon.com>
References: <20110316022804.27676.qmail@science.horizon.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Mar 2011 21:57:18 -0500
Message-ID: <1300244238.3128.420.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2011-03-13 at 20:20 -0400, George Spelvin wrote:
> As a followup to the "[PATCH] Make /proc/slabinfo 0400" thread, this
> is a patch series to randomize the order of object allocations within
> a page.  It can be extended to SLAB and SLOB if desired.  Mostly it's
> for benchmarking and discussion.

I've spent a while thinking about this over the past few weeks, and I
really don't think it's productive to try to randomize the allocators.
It provides negligible defense and just makes life harder for kernel
hackers.

(And you definitely can't randomize SLOB like this.)

> Patches 1-4 and 8 touch drivers/char/random.c, to add support for
> efficiently generating a series of uniform random integers in small
> ranges.  Is this okay with Herbert & Matt?

But I will look at these.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
