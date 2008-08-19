Subject: Re: [patch] mm: page allocator minor speedup
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20080819074911.GA10447@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de>
	 <20080818122957.GE9062@wotan.suse.de>
	 <84144f020808180657v2bdd5f76l4b0f1897c73ec0c0@mail.gmail.com>
	 <20080819074911.GA10447@wotan.suse.de>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 19 Aug 2008 10:51:41 +0300
Message-Id: <1219132301.7813.358.camel@penberg-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Mon, Aug 18, 2008 at 3:29 PM, Nick Piggin <npiggin@suse.de> wrote:
> > > Now that we don't put a ZERO_PAGE in the pagetables any more, and the
> > > "remove PageReserved from core mm" patch has had a long time to mature,
> > > let's remove the page reserved logic from the allocator.
> > >
> > > This saves several branches and about 100 bytes in some important paths.
i>>?
On Mon, Aug 18, 2008 at 04:57:00PM +0300, Pekka Enberg wrote:
> > Cool. Any numbers for this?

i>>?On Tue, 2008-08-19 at 09:49 +0200, Nick Piggin wrote:
> No, no numbers. I expect it would be very difficult to measure because
> it probably only starts saving cycles when the workload exceeds L1I and/or
> the branch caches.

OK, I am asking this because any improvements in the page allocator fast
paths are going to be a gain for SLUB intensive workloads as well.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
