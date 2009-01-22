Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5049B6B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 05:01:27 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so2109736fge.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2009 02:01:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
	 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
Date: Thu, 22 Jan 2009 12:01:24 +0200
Message-ID: <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Wed, Jan 21, 2009 at 8:10 PM, Hugh Dickins <hugh@veritas.com> wrote:
> I was initially _very_ impressed by how well it did on my venerable
> tmpfs loop swapping loads, where I'd expected next to no effect; but
> that turned out to be because on three machines I'd been using SLUB,
> without remembering how default slub_max_order got raised from 1 to 3
> in 2.6.26 (hmm, and Documentation/vm/slub.txt not updated).
>
> That's been making SLUB behave pretty badly (e.g. elapsed time 30%
> more than SLAB) with swapping loads on most of my machines.  Though
> oddly one seems immune, and another takes four times as long: guess
> it depends on how close to thrashing, but probably more to investigate
> there.  I think my original SLUB versus SLAB comparisons were done on
> the immune one: as I remember, SLUB and SLAB were equivalent on those
> loads when SLUB came in, but even with boot option slub_max_order=1,
> SLUB is still slower than SLAB on such tests (e.g. 2% slower).
> FWIW - swapping loads are not what anybody should tune for.

What kind of machine are you seeing this on? It sounds like it could
be a side-effect from commit 9b2cd506e5f2117f94c28a0040bf5da058105316
("slub: Calculate min_objects based on number of processors").

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
