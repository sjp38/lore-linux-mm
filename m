Date: Tue, 9 Aug 2005 20:41:00 +0100
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Message-ID: <20050809204100.B29945@flint.arm.linux.org.uk>
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de> <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au> <20050809080853.A25492@flint.arm.linux.org.uk> <523240000.1123598289@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <523240000.1123598289@[10.10.2.4]>; from mbligh@mbligh.org on Tue, Aug 09, 2005 at 07:38:52AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 09, 2005 at 07:38:52AM -0700, Martin J. Bligh wrote:
> pfn_valid() doesn't tell you it's RAM or not - it tells you whether you
> have a backing struct page for that address. Could be an IO mapped device,
> a small memory hole, whatever.

The only things which have a struct page is RAM.  Nothing else does.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
