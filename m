Date: Wed, 18 Feb 2004 16:28:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-Id: <20040218162858.2a230401.akpm@osdl.org>
In-Reply-To: <20040218230055.A14889@infradead.org>
References: <20040216190927.GA2969@us.ibm.com>
	<20040217073522.A25921@infradead.org>
	<20040217124001.GA1267@us.ibm.com>
	<20040217161929.7e6b2a61.akpm@osdl.org>
	<1077108694.4479.4.camel@laptop.fenrus.com>
	<20040218140021.GB1269@us.ibm.com>
	<20040218211035.A13866@infradead.org>
	<20040218150607.GE1269@us.ibm.com>
	<20040218222138.A14585@infradead.org>
	<20040218145132.460214b5.akpm@osdl.org>
	<20040218230055.A14889@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: paulmck@us.ibm.com, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> Yes.  Andrew, please read the GPL, it's very clear about derived works.
> Then please tell me why you think gpfs is not a derived work.

OK, so I looked at the wrapper.  It wasn't a tremendously pleasant
experience.  It is huge, and uses fairly standard-looking filesytem
interfaces and locking primitives.  Also some awareness of NFSV4 for some
reason.

Still, the wrapper is GPL so this is not relevant.  Its only use is to tell
us whether or not the non-GPL bits are "derived" from Linux, and it
doesn't do that.

The GPL doesn't define a derived work.  It says

  "If identifiable sections of that work are not derived from the
   Program, and can be reasonably considered independent and separate works
   in themselves, then this License, and its terms, do not apply to those
   sections when you distribute them as separate works.  But when you
   distribute the same sections as part of a whole which is a work based on
   the Program, the distribution of the whole must be on the terms of this
   License, ..."

And the "But when you distribute..." part is what the Linus doctrine rubs
out.  Because it is unreasonable to say that a large piece of work such as
this is "derived" from Linux.

Why do you believe that GPFS represents a kernel licensing violation?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
