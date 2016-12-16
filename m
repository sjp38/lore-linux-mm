Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3773C6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 12:14:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so130394744pfb.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:14:20 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0087.outbound.protection.outlook.com. [104.47.36.87])
        by mx.google.com with ESMTPS id a3si8635075plc.19.2016.12.16.09.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Dec 2016 09:14:18 -0800 (PST)
Date: Fri, 16 Dec 2016 18:14:06 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20161216171406.GE4930@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20161215153930.GA8111@rric.localdomain>
 <125f3064-bbec-d923-ad9f-b2d152ee2c2d@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <125f3064-bbec-d923-ad9f-b2d152ee2c2d@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org, xieyisheng1@huawei.com, james.morse@arm.com

On 16.12.16 09:57:20, Hanjun Guo wrote:
> Hi Robert,
> 
> On 2016/12/15 23:39, Robert Richter wrote:
> >I was going to do some measurements but my kernel crashes now with a
> >page fault in efi_rtc_probe():
> >
> >[   21.663393] Unable to handle kernel paging request at virtual address 20251000
> >[   21.663396] pgd = ffff000009090000
> >[   21.663401] [20251000] *pgd=0000010ffff90003
> >[   21.663402] , *pud=0000010ffff90003
> >[   21.663404] , *pmd=0000000fdc030003
> >[   21.663405] , *pte=00e8832000250707
> >
> >The sparsemem config requires the whole section to be initialized.
> >Your patches do not address this.
> 
> This patch set is running properly on D05, both the boot and
> LTP MM stress test are ok, seems it's a different configuration
> of memory mappings in firmware, just a stupid question, which
> part is related to this problem, is it only the Reserved memory?

The problem are efi reserved regions that are no longer reserved but
marked as nomap pages. Those are excluded from page initialization
causing parts of a memory section not being initialized.

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
