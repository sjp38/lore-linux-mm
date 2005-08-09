Date: Tue, 09 Aug 2005 07:38:52 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Message-ID: <523240000.1123598289@[10.10.2.4]>
In-Reply-To: <20050809080853.A25492@flint.arm.linux.org.uk>
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de> <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au> <20050809080853.A25492@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

--Russell King <rmk+lkml@arm.linux.org.uk> wrote (on Tuesday, August 09, 2005 08:08:53 +0100):

> On Tue, Aug 09, 2005 at 02:59:53PM +1000, Nick Piggin wrote:
>> That would work for swsusp, but there are other users that want to
>> know if a struct page is valid ram (eg. ioremap), so in that case
>> swsusp would not be able to mess with the flag.
> 
> The usage of "valid ram" here is confusing - that's not what PageReserved
> is all about.  It's about valid RAM which is managed by method other
> than the usual page counting.  Non-reserved RAM is also valid RAM, but
> is managed by the kernel in the usual way.
> 
> The former is available for remap_pfn_range and ioremap, the latter is
> not.
> 
> On the other hand, the validity of an apparant RAM address can only be
> tested using its pfn with pfn_valid().
> 
> Can we straighten out the terminology so it's less confusing please?

pfn_valid() doesn't tell you it's RAM or not - it tells you whether you
have a backing struct page for that address. Could be an IO mapped device,
a small memory hole, whatever.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
