Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 92DA06B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 10:59:27 -0500 (EST)
Date: Wed, 14 Jan 2009 16:59:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090114155923.GC1616@wotan.suse.de>
References: <20090114090449.GE2942@wotan.suse.de> <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com> <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com> <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de> <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 14, 2009 at 05:30:48PM +0200, Pekka Enberg wrote:
> Hi Nick,
> 
> On Wed, Jan 14, 2009 at 5:22 PM, Nick Piggin <npiggin@suse.de> wrote:
> > And... IIRC, the Intel guys did make a stink but it wasn't considered
> > so important or worthwhile to fix for some reason? Anyway, the fact is
> > that it hadn't been fixed in SLUB. Hmm, I guess it is a significant
> > failure of SLUB that it hasn't managed to replace SLAB by this point.
> 
> Again, not speaking for Christoph, but *I* do consider the regression
> to be important and I do want it to be fixed. I have asked for a test
> case to reproduce the regression and/or oprofile reports but have yet
> to receive them. I did fix one regression I saw with the fio benchmark
> but unfortunately it wasn't the same regression the Intel guys are
> hitting. I suppose we're in limbo now because the people who are
> affected by the regression can simply turn on CONFIG_SLAB.

Mmm. SLES11 will ship with CONFIG_SLAB, FWIW. No I actually didn't
make any input into the decision. And I have mixed feelings about
that because there are places where SLAB is better.

But I must say that SLAB seems to be a really good allocator, and
outside of some types of microbenchmarks where it would sometimes
be much slower than SLAB, SLAB was often my main performance competitor
and often very hard to match with SLQB, let alone beat. That's not
to say SLUB wasn't also often the faster of the two, but I was
surprised at how good SLAB is.

 
> In any case, I do agree that the inability to replace SLAB with SLUB
> is a failure on the latter. I'm just not totally convinced that it's
> because the SLUB code is unfixable ;).

Well if you would like to consider SLQB as a fix for SLUB, that's
fine by me ;) Actually I guess it is a valid way to look at the problem:
SLQB solves the OLTP regression, so the only question is "what is the
downside of it?".



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
