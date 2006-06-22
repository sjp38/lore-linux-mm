Date: Thu, 22 Jun 2006 09:37:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] mm: remove some update_mmu_cache() calls
In-Reply-To: <Pine.LNX.4.64.0606221646000.4977@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0606220935130.28760@schroedinger.engr.sgi.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175347.24655.67680.sendpatchset@lappy>
 <Pine.LNX.4.64.0606221646000.4977@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2006, Hugh Dickins wrote:

> The answer I expect is that update_mmu_cache is essential there in
> do_wp_page (reuse case) and handle_pte_fault, on at least some if
> not all of those arches which implement it.  That without those
> lines, they'll fault and refault endlessly, since the "MMU cache"
> has not been updated with the write permission.

Yes a likely scenario.
 
> But omitted from mprotect, since that's dealing with a batch of
> pages, perhaps none of which will be faulted in the near future:
> a waste of resources to update for all those entries.

So we intentially allow mprotect to be racy?

> But now I wonder, why does do_wp_page reuse case flush_cache_page?

Some arches may have virtual caches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
