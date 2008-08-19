Date: Tue, 19 Aug 2008 09:49:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: page allocator minor speedup
Message-ID: <20080819074911.GA10447@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de> <20080818122957.GE9062@wotan.suse.de> <84144f020808180657v2bdd5f76l4b0f1897c73ec0c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020808180657v2bdd5f76l4b0f1897c73ec0c0@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 18, 2008 at 04:57:00PM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Mon, Aug 18, 2008 at 3:29 PM, Nick Piggin <npiggin@suse.de> wrote:
> > Now that we don't put a ZERO_PAGE in the pagetables any more, and the
> > "remove PageReserved from core mm" patch has had a long time to mature,
> > let's remove the page reserved logic from the allocator.
> >
> > This saves several branches and about 100 bytes in some important paths.
> 
> Cool. Any numbers for this?

No, no numbers. I expect it would be very difficult to measure because
it probably only starts saving cycles when the workload exceeds L1I and/or
the branch caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
