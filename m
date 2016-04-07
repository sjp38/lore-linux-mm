Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9D16B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 03:44:50 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id zm5so50061847pac.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 00:44:50 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id b5si10010388pat.133.2016.04.07.00.44.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Apr 2016 00:44:49 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <57060E79.8030801@hisilicon.com>
Date: Thu, 7 Apr 2016 15:38:33 +0800
MIME-Version: 1.0
In-Reply-To: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org, mgorman@suse.de
Cc: puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

add Mel Gorman

On 2016/4/5 16:22, Chen Feng wrote:
> We can reduce the memory allocated at mem-map
> by flatmem.
> 
> currently, the default memory-model in arm64 is
> sparse memory. The mem-map array is not freed in
> this scene. If the physical address is too long,
> it will reserved too much memory for the mem-map
> array.
> 
> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> Signed-off-by: Fu Jun <oliver.fu@hisilicon.com>
> ---
>  arch/arm64/Kconfig | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 4f43622..c18930d 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -559,6 +559,9 @@ config ARCH_SPARSEMEM_ENABLE
>  	def_bool y
>  	select SPARSEMEM_VMEMMAP_ENABLE
>  
> +config ARCH_FLATMEM_ENABLE
> +	def_bool y
> +
>  config ARCH_SPARSEMEM_DEFAULT
>  	def_bool ARCH_SPARSEMEM_ENABLE
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
