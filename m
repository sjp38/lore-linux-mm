Date: Tue, 19 Feb 2002 16:14:12 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: rmap for ARMV.
Message-ID: <20020219161412.B16613@flint.arm.linux.org.uk>
References: <22292.1014134494@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22292.1014134494@redhat.com>; from dwmw2@infradead.org on Tue, Feb 19, 2002 at 04:01:34PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2002 at 04:01:34PM +0000, David Woodhouse wrote:
> ARM was fun because it has a slab cache with 2KiB objects for page tables, 
> rather than allocating them a page at a time - so we couldn't just use
> page->{mapping,index} for each page as we do on other architectures.

When rmap gets merged into the 2.5 kernel series, I'll look at what
can be done to sort out the pte situation - we could re-jig the page
tables so a 'pgd' is 8 bytes per entry (made up of two hardware PTE
pointers), the second level page tables end up being 2K hardware + 2K
for Linux, which nicely maps to a page per PTE as viewed by Linux.

This should simplify this patch, as well as getting rid of the pte
slab.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
