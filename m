Date: Mon, 1 Dec 2008 23:19:50 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/8] badpage: keep any bad page out of circulation
In-Reply-To: <Pine.LNX.4.64.0812010848160.15331@quilx.com>
Message-ID: <Pine.LNX.4.64.0812012308470.18893@blonde.anvils>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
 <Pine.LNX.4.64.0812010040330.11401@blonde.site> <Pine.LNX.4.64.0812010848160.15331@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Christoph Lameter wrote:
> On Mon, 1 Dec 2008, Hugh Dickins wrote:
> 
> > Until now the bad_page() checkers have special-cased PageReserved, keeping
> > those pages out of circulation thereafter.  Now extend the special case to
> > all: we want to keep ANY page with bad state out of circulation - the
> > "free" page may well be in use by something.
> 
> If I screw up with a VM patch

Oh, perish the thought!

> then my machine will now die because of OOM
> instead of letting me shutdown and reboot?

If you screw up so royally as to allocate every page in the machine
and free it with bad state, yes, that's indeed the way it will tend.
Or, to the extent that you're relying on high orders and low zones,
it will happen even sooner.  Same as if you screw up and forget to
free your pages.

That's okay.  In more normal cases you'll see the warnings before
it's dead, and shutdown and reboot (hopefully a different kernel!)
before it reaches that state.  By the time your patches reach -mm,
I'd hope you'll have weeded out the immediate OOM cases.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
