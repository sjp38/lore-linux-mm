Date: Fri, 23 Jun 2006 19:41:45 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
Message-ID: <20060623184145.GA22172@infradead.org>
References: <20060619175243.24655.76005.sendpatchset@lappy> <20060619175253.24655.96323.sendpatchset@lappy> <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com> <1151019590.15744.144.camel@lappy> <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org> <Pine.LNX.4.64.0606230759480.19782@blonde.wat.veritas.com> <Pine.LNX.4.64.0606230955230.6265@schroedinger.engr.sgi.com> <1151083338.30819.28.camel@lappy> <Pine.LNX.4.64.0606231055520.6483@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0606231055520.6483@g5.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 23, 2006 at 10:56:44AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 23 Jun 2006, Peter Zijlstra wrote:
> > 
> > I intent to make swap over NFS work next.
> 
> Doesn't it work already? Is there some throttling that doesn't work?

With the current code it definitly doesn't.  The swap code calls ->bmap
to do block mappings at swapon time and then uses bios directly. This
obviously can't work on anything but blockdevice-based filesystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
