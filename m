Date: Wed, 18 Feb 2004 15:32:34 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-Id: <20040218153234.3956af3a.akpm@osdl.org>
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

I haven't seen the code.

> > But at the end of the day, if we decide to not export this symbol, we owe
> > Paul a good, solid reason, yes?
> 
> Yes.  We've traditionally not exported symbols unless we had an intree user,
> and especially not if it's for a module that's not GPL licensed.

That's certainly a good rule of thumb and we (and I) have used it before.

What is the reasoning behind it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
