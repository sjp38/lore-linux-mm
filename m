Date: Tue, 14 Dec 2004 20:13:48 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <20041214191348.GA27225@wotan.suse.de>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9250000.1103050790@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2004 at 10:59:50AM -0800, Martin J. Bligh wrote:
> > NUMA systems running current Linux kernels suffer from substantial
> > inequities in the amount of memory allocated from each NUMA node
> > during boot.  In particular, several large hashes are allocated
> > using alloc_bootmem, and as such are allocated contiguously from
> > a single node each.
> 
> Yup, makes a lot of sense to me to stripe these, for the caches that

I originally was a bit worried about the TLB usage, but it doesn't
seem to be a too big issue (hopefully the benchmarks weren't too
micro though)

> didn't Manfred or someone (Andi?) do this before? Or did that never
> get accepted? I know we talked about it a while back.

I talked about it, but never implemented it. I am not aware of any
other implementation of this before Brent's.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
