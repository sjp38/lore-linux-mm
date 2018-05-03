Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09FE86B0011
	for <linux-mm@kvack.org>; Thu,  3 May 2018 04:48:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f19-v6so11706872pgv.4
        for <linux-mm@kvack.org>; Thu, 03 May 2018 01:48:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id l18si13403650pfe.299.2018.05.03.01.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 01:48:42 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
References: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <1bc3ec9e-606b-e019-f870-ce4a2520cdbf@codeaurora.org>
Date: Thu, 3 May 2018 14:18:32 +0530
MIME-Version: 1.0
In-Reply-To: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>, ldufour@linux.vnet.ibm.com, catalin.marinas@arm.com, will.deacon@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org



On 5/2/2018 1:24 PM, Ganesh Mahendran wrote:
> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> enables Speculative Page Fault handler.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
> This patch is on top of Laurent's v10 spf
> ---
>   arch/arm64/Kconfig | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index eb2cf49..cd583a9 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -144,6 +144,7 @@ config ARM64
>   	select SPARSE_IRQ
>   	select SYSCTL_EXCEPTION_TRACE
>   	select THREAD_INFO_IN_TASK
> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if SMP
>   	help
>   	  ARM 64-bit (AArch64) Linux support.
>   
> 

You may also consider re-ordering of patches in next version. Generally,
config enablement assumes effectiveness of that config.

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
