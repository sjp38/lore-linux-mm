Date: Sat, 10 Mar 2007 23:04:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V5
In-Reply-To: <20070310224946.f9385917.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703102259440.23001@schroedinger.engr.sgi.com>
References: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
 <20070310224946.f9385917.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, 10 Mar 2007, Andrew Morton wrote:

> Is this safe to think about applying yet?

Its safe. By default kernels will be build with SLAB. SLUB becomes only a 
selectable alternative. It should not become the primary slab until we 
know that its really superior overall and have thoroughly tested it in
a variety of workloads.

> We lost the leak detector feature.

There will be numerous small things that will have to be addressed. There
is also some minor work to be done for tracking callers better.
 
> It might be nice to create synonyms for PageActive, PageReferenced and
> PageError, to make things clearer in the slub core.   At the expense of
> making things less clear globally.  Am unsure.

I have been back and forth on doing that. There are somewhat similar 
in what they mean for SLUB. But creating synonyms may be confusing to 
those checking how page flags are being used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
