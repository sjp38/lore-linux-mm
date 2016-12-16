Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC596B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 20:57:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so149625100pgd.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 17:57:26 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id u3si4981808plb.141.2016.12.15.17.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 17:57:25 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id 189so11453042pfz.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 17:57:25 -0800 (PST)
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20161215153930.GA8111@rric.localdomain>
From: Hanjun Guo <hanjun.guo@linaro.org>
Message-ID: <125f3064-bbec-d923-ad9f-b2d152ee2c2d@linaro.org>
Date: Fri, 16 Dec 2016 09:57:20 +0800
MIME-Version: 1.0
In-Reply-To: <20161215153930.GA8111@rric.localdomain>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org, xieyisheng1@huawei.com, james.morse@arm.com

Hi Robert,

On 2016/12/15 23:39, Robert Richter wrote:
> I was going to do some measurements but my kernel crashes now with a
> page fault in efi_rtc_probe():
>
> [   21.663393] Unable to handle kernel paging request at virtual address 20251000
> [   21.663396] pgd = ffff000009090000
> [   21.663401] [20251000] *pgd=0000010ffff90003
> [   21.663402] , *pud=0000010ffff90003
> [   21.663404] , *pmd=0000000fdc030003
> [   21.663405] , *pte=00e8832000250707
>
> The sparsemem config requires the whole section to be initialized.
> Your patches do not address this.

This patch set is running properly on D05, both the boot and
LTP MM stress test are ok, seems it's a different configuration
of memory mappings in firmware, just a stupid question, which
part is related to this problem, is it only the Reserved memory?

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
