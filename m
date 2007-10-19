Date: Thu, 18 Oct 2007 18:21:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Avoid atomic operation for slab_unlock
In-Reply-To: <200710190949.01019.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710181817380.4194@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com>
 <200710190949.01019.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Oct 2007, Nick Piggin wrote:

> Ah, thanks, but can we just use my earlier patch that does the
> proper __bit_spin_unlock which is provided by
> bit_spin_lock-use-lock-bitops.patch

Ok.

> This primitive should have a better chance at being correct, and
> also potentially be more optimised for each architecture (it
> only has to provide release consistency).

Yes that is what I attempted to do with the write barrier. To my knowledge 
there are no reads that could bleed out and I wanted to avoid a full fence 
instruction there.

> I have attached the patch here just for reference, but actually
> I am submitting it properly as part of a patch series today, now
> that the base bit lock patches have been sent upstream.

Good. Andrew: Drop my patch when this goes in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
