Date: Thu, 19 Feb 2004 10:56:08 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-Id: <20040219105608.30d2c51e.akpm@osdl.org>
In-Reply-To: <20040219123237.B22406@infradead.org>
References: <20040217124001.GA1267@us.ibm.com>
	<20040217161929.7e6b2a61.akpm@osdl.org>
	<1077108694.4479.4.camel@laptop.fenrus.com>
	<20040218140021.GB1269@us.ibm.com>
	<20040218211035.A13866@infradead.org>
	<20040218150607.GE1269@us.ibm.com>
	<20040218222138.A14585@infradead.org>
	<20040218145132.460214b5.akpm@osdl.org>
	<20040218230055.A14889@infradead.org>
	<20040218153234.3956af3a.akpm@osdl.org>
	<20040219123237.B22406@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: paulmck@us.ibm.com, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> On Wed, Feb 18, 2004 at 03:32:34PM -0800, Andrew Morton wrote:
> > > Yes.  We've traditionally not exported symbols unless we had an intree user,
> > > and especially not if it's for a module that's not GPL licensed.
> > 
> > That's certainly a good rule of thumb and we (and I) have used it before.
> > 
> > What is the reasoning behind it?
> 
> The reason is that someone who wants to distribute a binary only module
> has to show it's module is not a derived work, and someone who needs new
> core in the kernel and new exports pretty much shows his work is deeply
> integrated with the kernel.

Needing access to invalidate_mmap_range() is surely not an indication of a
derived work.  It is an indication of a need for a reliable way to achieve
inter-node cache consistency.  Other distributed filesystems will need this
and probably AIX already provides it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
