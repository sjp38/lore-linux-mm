Date: Fri, 28 Jun 2002 11:01:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] find_vma_prev rewrite
Message-ID: <20020628180154.GS25360@holomorphy.com>
References: <20020627160757.A13056@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020627160757.A13056@parcelfarce.linux.theplanet.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <willy@debian.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2002 at 04:07:57PM +0100, Matthew Wilcox wrote:
> I've been sending patches like this for over 18 months now with
> no comments.  I'm sending it to Linus early next week.  It benefits
> ia64's fault handler path and is required for PA-RISC's fault handler.
> It works, it's tested.  I realise this puts it in a very different class
> from the kind of VM patches which are allowed in a stable kernel tree.

That's discouraging to hear... perhaps some other time to discuss it.


On Thu, Jun 27, 2002 at 04:07:57PM +0100, Matthew Wilcox wrote:
> There's also a chunk after find_vma_prev which adds an implementation
> of find_extend_vma for machines with stacks which grow up.  I couldn't
> be bothered to split it out, since it won't affect any other architecture.

It should be there for correctness.

I say it should go in.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
