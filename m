Date: Wed, 12 Jan 2005 18:04:32 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: page table lock patch V15 [0/7]: overview
Message-ID: <20050112180432.GA6264@infradead.org>
References: <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de> <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com> <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org> <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com> <20050112164906.GA4935@infradead.org> <Pine.LNX.4.58.0501120931460.10697@schroedinger.engr.sgi.com> <20050112174101.GA5838@infradead.org> <Pine.LNX.4.58.0501120951140.10806@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501120951140.10806@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 12, 2005 at 09:52:53AM -0800, Christoph Lameter wrote:
> On Wed, 12 Jan 2005, Christoph Hellwig wrote:
> 
> > These smaller systems are more likely x86/x86_64 machines ;-)
> 
> But they will not have been build in 1998 either like the machine I used
> for the i386 tests. Could you do some tests on contemporary x86/x86_64
> SMP systems with large memory?

I don't have such systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
