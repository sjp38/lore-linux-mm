Date: Sat, 5 May 2007 08:39:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Slab Defrag / Slab Targeted Reclaim and general Slab
 API changes
In-Reply-To: <463C1900.7060409@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0705050835480.26574@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com> <463C10F8.4040803@cosmosbay.com>
 <Pine.LNX.4.64.0705042209050.14211@schroedinger.engr.sgi.com>
 <463C1900.7060409@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 5 May 2007, Eric Dumazet wrote:

> > Then add ___cacheline_aligned_in_smp or specify the alignment in the various
> > other ways that exist. Practice is that most slabs specify
> > SLAB_HWCACHE_ALIGN. So most slabs are cache aligned today.
> 
> Yes but this alignement is dynamic, not at compile time.
> 
> include/asm-i386/processor.h:739:#define cache_line_size()
> (boot_cpu_data.x86_cache_alignment)

Ahh.. I did not see that before.

> So adding ____cacheline_aligned  to 'struct file' for example would be a
> regression for people with PII or PIII

Yuck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
