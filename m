Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8A2DB6B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 09:45:17 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so289946fge.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2009 06:45:15 -0800 (PST)
Message-ID: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
Date: Wed, 14 Jan 2009 16:45:15 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090114142200.GB25401@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090114090449.GE2942@wotan.suse.de>
	 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
	 <20090114114707.GA24673@wotan.suse.de>
	 <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
	 <20090114142200.GB25401@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Wed, Jan 14, 2009 at 4:22 PM, Nick Piggin <npiggin@suse.de> wrote:
> The problem is there was apparently no plan for resolving the SLAB vs SLUB
> strategy. And then features and things were added to one or the other one.
> But on the other hand, the SLUB experience was a success in a way because
> there were a lot of performance regressions found and fixed after it was
> merged, for example.

That's not completely true. I can't speak for Christoph, but the
biggest problem I have is that I have _no way_ of reproducing or
analyzing the regression. I've tried out various benchmarks I have
access to but I haven't been able to find anything.

The hypothesis is that SLUB regresses because of kmalloc()/kfree()
ping-pong between CPUs and as far as I understood, Christoph thinks we
can improve SLUB with the per-cpu alloc patches and the freelist
management rework.

Don't get me wrong, though. I am happy you are able to work with the
Intel engineers to fix the long standing issue (I want it fixed too!)
but I would be happier if the end-result was few simple patches
against mm/slub.c :-).

On Wed, Jan 14, 2009 at 4:22 PM, Nick Piggin <npiggin@suse.de> wrote:
> I'd love to be able to justify replacing SLAB and SLUB today, but actually
> it is simply never going to be trivial to discover performance regressions.
> So I don't think outright replacement is great either (consider if SLUB
> had replaced SLAB completely).

If you ask me, I wish we *had* removed SLAB so relevant people could
have made a huge stink out of it and the regression would have been
taken care quickly ;-).

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
