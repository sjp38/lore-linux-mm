Date: Thu, 19 Feb 2004 12:31:10 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219123110.A22406@infradead.org>
References: <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218162858.2a230401.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040218162858.2a230401.akpm@osdl.org>; from akpm@osdl.org on Wed, Feb 18, 2004 at 04:28:58PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, torvalds@osd.org
Cc: Christoph Hellwig <hch@infradead.org>, paulmck@us.ibm.com, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 18, 2004 at 04:28:58PM -0800, Andrew Morton wrote:
> OK, so I looked at the wrapper.  It wasn't a tremendously pleasant
> experience.  It is huge, and uses fairly standard-looking filesytem
> interfaces and locking primitives.  Also some awareness of NFSV4 for some
> reason.

And pokes deep into internal structures that it shouldn't.

> Still, the wrapper is GPL so this is not relevant.

It's BSD licensed - they couldn't distribute it together with GPFS if
it was GPL.

> Its only use is to tell
> us whether or not the non-GPL bits are "derived" from Linux, and it
> doesn't do that.

Well, something that needs an almost one megabyte big wrapper per defintion
is not a standalone work but something that's deeply interwinded with
the kernel.  The tons of kernel version checks certainly show it's poking
deeper than it should.

> Why do you believe that GPFS represents a kernel licensing violation?

See above.  Something that pokes deep into internal structures and even
needs new exports certainly is a derived work.  There's a few different
interpretations of the derived works clause in the GPL around, the FSF
one wouldn't allow binary modules at all, and Linus' one is also pretty
strict.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
