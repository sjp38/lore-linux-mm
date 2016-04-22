Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB12A6B025E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 05:07:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so109354322pfy.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 02:07:49 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gc5si6623663pac.224.2016.04.22.02.07.48
        for <linux-mm@kvack.org>;
        Fri, 22 Apr 2016 02:07:48 -0700 (PDT)
Date: Fri, 22 Apr 2016 10:07:45 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH resend 0/3] mm: allow arch to override lowmem_page_address
Message-ID: <20160422090744.GB4236@arm.com>
References: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
 <20160421165138.a57be293ec370d5ea014e1ae@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160421165138.a57be293ec370d5ea014e1ae@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lftan@altera.com, jonas@southpole.se

On Thu, Apr 21, 2016 at 04:51:38PM -0700, Andrew Morton wrote:
> On Mon, 18 Apr 2016 18:04:54 +0200 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> 
> > These patches allow the arch to define the page_to_virt() conversion that
> > is used in lowmem_page_address(). This is desirable for arm64, where this
> > conversion is trivial when CONFIG_SPARSEMEM_VMEMMAP is enabled, while
> > breaking it up into __va(PFN_PHYS(page_to_pfn(page))), as is done currently
> > in lowmem_page_address(), will force the use of a virt-to-phys() conversion
> > and back again, which always involves a memory access on arm64, since the
> > start of physical memory is not a compile time constant.
> > 
> > I have split off these patches from my series 'arm64: optimize virt_to_page
> > and page_address' which I sent out 3 weeks ago, and resending them in the
> > hope that they can be picked up (with Will's ack on #3) to be merged via
> > the mm tree.
> > 
> > I have cc'ed the nios2 and openrisc maintainers on previous versions, and
> > cc'ing them again now. I have dropped both of the arch specific mailing
> > lists, since one is defunct and the other is subscriber only.
> > 
> > Andrew, is this something you would be pulling to pick up (assuming that you
> > agree with the contents)? Thanks.
> 
> Looks OK to me and apart from the trivial openrisc/nios2 changes it's
> obviously a no-op for all-but-arm.  So I suggest you include these
> patches in the appropriate arm tree.
> 
> Acked-by: Andrew Morton <akpm@linux-foundation.org>

Cracking, thanks Andrew. I'll queue these three in the arm64 tree and get
them into -next.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
