Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8000B6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 11:31:28 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so409315pbb.8
        for <linux-mm@kvack.org>; Tue, 13 May 2014 08:31:28 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bl9si13657506pad.130.2014.05.13.08.31.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 08:31:27 -0700 (PDT)
Message-ID: <53723ACC.7020500@codeaurora.org>
Date: Tue, 13 May 2014 11:31:24 -0400
From: Christopher Covington <cov@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5 4/6] arm: mm: Enable RCU fast_gup
References: <1399390209-1756-1-git-send-email-steve.capper@linaro.org> <1399390209-1756-5-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1399390209-1756-5-git-send-email-steve.capper@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, anders.roxell@linaro.org, peterz@infradead.org, gary.robertson@linaro.org, will.deacon@arm.com, akpm@linux-foundation.org, christoffer.dall@linaro.org

Hi Steve,

On 05/06/2014 11:30 AM, Steve Capper wrote:
> Activate the RCU fast_gup for ARM. We also need to force THP splits to
> broadcast an IPI s.t. we block in the fast_gup page walker. As THP
> splits are comparatively rare, this should not lead to a noticeable
> performance degradation.

> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 3387e60..91a2b59 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -377,3 +377,22 @@ void __flush_anon_page(struct vm_area_struct *vma, struct page *page, unsigned l
>  	 */
>  	__cpuc_flush_dcache_area(page_address(page), PAGE_SIZE);
>  }
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#ifdef CONFIG_HAVE_RCU_TABLE_FREE

This is trivia, but I for one find the form #if defined(a) && defined(b)
easier to read. (Applies to the A64 version as well).

Christopher

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by the Linux Foundation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
