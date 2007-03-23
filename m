Date: Fri, 23 Mar 2007 07:58:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <20070323112331.GQ2986@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0703230757420.21787@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
 <20070322234848.100abb3d.akpm@linux-foundation.org> <20070323112331.GQ2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007, William Lee Irwin III wrote:

> [... patch changing allocator alloc()/free() to bare page allocations ...]
> > but it crashes early in the page allocator (i386) and I don't see why.  It
> > makes me wonder if we have a use-after-free which is hidden by the presence
> > of the quicklist buffering or something.

Sorry there seems to be some email dropouts today. I am getting 
fragments of slab and quicklist discussions. Maybe I can get the whole story from 
the mailing lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
