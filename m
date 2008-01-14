Date: Mon, 14 Jan 2008 11:11:33 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
	large count NR_CPUs
Message-ID: <20080114101133.GA23238@elte.hu>
References: <20080113183453.973425000@sgi.com> <20080114081418.GB18296@elte.hu> <200801141104.18789.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200801141104.18789.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Andi Kleen <ak@suse.de> wrote:

> > i.e. we've got ~22K bloat per CPU - which is not bad, but because 
> > it's a static component, it hurts smaller boxes. For distributors to 
> > enable CONFIG_NR_CPU=1024 by default i guess that bloat has to drop 
> > below 1-2K per CPU :-/ [that would still mean 1-2MB total bloat but 
> > that's much more acceptable than 23MB]
> 
> Even 1-2MB overhead would be too much for distributors I think. 
> Ideally there must be near zero overhead for possible CPUs (and I see 
> no principle reason why this is not possible) Worst case a low few 
> hundred KBs, but even that would be much.

i think this patchset already gives a net win, by moving stuff from 
NR_CPUS arrays into per_cpu area. (Travis please confirm that this is 
indeed what the numbers show)

The (total-)size of the per-cpu area(s) grows linearly with the number 
of CPUs, so we'll have the expected near-zero overhead on 4-8-16-32 CPUs 
and the expected larger total overhead on 1024 CPUs.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
