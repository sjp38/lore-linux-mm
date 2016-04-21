Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8B45830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 19:51:39 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so83559761pab.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 16:51:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e184si3208481pfe.83.2016.04.21.16.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 16:51:38 -0700 (PDT)
Date: Thu, 21 Apr 2016 16:51:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend 0/3] mm: allow arch to override
 lowmem_page_address
Message-Id: <20160421165138.a57be293ec370d5ea014e1ae@linux-foundation.org>
In-Reply-To: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lftan@altera.com, jonas@southpole.se, will.deacon@arm.com

On Mon, 18 Apr 2016 18:04:54 +0200 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> These patches allow the arch to define the page_to_virt() conversion that
> is used in lowmem_page_address(). This is desirable for arm64, where this
> conversion is trivial when CONFIG_SPARSEMEM_VMEMMAP is enabled, while
> breaking it up into __va(PFN_PHYS(page_to_pfn(page))), as is done currently
> in lowmem_page_address(), will force the use of a virt-to-phys() conversion
> and back again, which always involves a memory access on arm64, since the
> start of physical memory is not a compile time constant.
> 
> I have split off these patches from my series 'arm64: optimize virt_to_page
> and page_address' which I sent out 3 weeks ago, and resending them in the
> hope that they can be picked up (with Will's ack on #3) to be merged via
> the mm tree.
> 
> I have cc'ed the nios2 and openrisc maintainers on previous versions, and
> cc'ing them again now. I have dropped both of the arch specific mailing
> lists, since one is defunct and the other is subscriber only.
> 
> Andrew, is this something you would be pulling to pick up (assuming that you
> agree with the contents)? Thanks.

Looks OK to me and apart from the trivial openrisc/nios2 changes it's
obviously a no-op for all-but-arm.  So I suggest you include these
patches in the appropriate arm tree.

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
