From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with large count NR_CPUs
Date: Wed, 16 Jan 2008 18:34:39 +1100
References: <20080113183453.973425000@sgi.com> <20080114101133.GA23238@elte.hu> <200801141230.56403.ak@suse.de>
In-Reply-To: <200801141230.56403.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801161834.39746.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 14 January 2008 22:30, Andi Kleen wrote:

> In general there are more scaling problems like this (e.g. it also doesn't
> make sense to scale kernel threads for each CPU thread for example).

I think in a lot of ways, per-CPU kernel threads scale OK. At least
they should mostly be dynamic, so they don't require overhead on
smaller systems. On larger systems, I don't know if there are too
many kernel problems with all those threads (except for userspace
tools sometimes don't report well).

And I think making them per-CPU can be much easier than tuning some
arbitrary algorithm to get a mix between parallelism and footprint.

For example, I'm finding that it might actually be worthwhile to move
some per-node and dynamically-controlled thread creation over to the
basic per-CPU scheme because of differences in topologies...

Anyway, that's just an aside.

Oh, just while I remember it also, something funny is that MAX_NUMNODES
can be bigger than NR_CPUS on x86. I guess one can have CPUless nodes,
but wouldn't it make sense to have an upper bound of NR_CPUS by default?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
