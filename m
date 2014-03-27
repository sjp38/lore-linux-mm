Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 90E566B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:11:38 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi5so6087727wib.11
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:11:37 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
        by mx.google.com with ESMTPS id w12si2745002wiv.65.2014.03.27.08.11.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 08:11:37 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so3274267wiw.6
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:11:36 -0700 (PDT)
Date: Thu, 27 Mar 2014 15:11:30 +0000
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH V2] mm: hugetlb: Introduce huge_pte_{page,present,young}
Message-ID: <20140327151129.GA5117@linaro.org>
References: <1395321473-1257-1-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395321473-1257-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com

On Thu, Mar 20, 2014 at 01:17:53PM +0000, Steve Capper wrote:
> Introduce huge pte versions of pte_page, pte_present and pte_young.
> 
> This allows ARM (without LPAE) to use alternative pte processing logic
> for huge ptes.
> 
> Generic implementations that call the standard pte versions are also
> added to asm-generic/hugetlb.h.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
> Changed in V2 - moved from #ifndef,#define macros to entries in
> asm-generic/hugetlb.h as it makes more sense to have these with the
> other huge_pte_. definitions.
> 
> The only other architecture I can see that does not use
> asm-generic/hugetlb.h is s390. This patch includes trivial definitions
> for huge_pte_{page,present,young} for s390.
> 
> I've compile-tested this for s390, but don't have one under my desk so
> have not been able to test it.
> ---
>  arch/s390/include/asm/hugetlb.h | 15 +++++++++++++++
>  include/asm-generic/hugetlb.h   | 15 +++++++++++++++
>  mm/hugetlb.c                    | 22 +++++++++++-----------
>  3 files changed, 41 insertions(+), 11 deletions(-)
> 

Hello,
I was just wondering if this patch looked reasonable to people?

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
