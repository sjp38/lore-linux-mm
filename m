Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAFBB6B0003
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:35:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b83so3433833wme.7
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 03:35:57 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id m10-v6si15657499wrh.458.2018.04.26.03.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 03:35:56 -0700 (PDT)
Subject: Re: [PATCH v2 9/9] powerpc/hugetlb: Enable hugetlb migration for
 ppc64
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1494926612-23928-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <69b4fae5-d413-4866-7ce4-3873d3c6590f@c-s.fr>
Date: Thu, 26 Apr 2018 12:35:55 +0200
MIME-Version: 1.0
In-Reply-To: <1494926612-23928-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, mpe@ellerman.id.au
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org



Le 16/05/2017 A  11:23, Aneesh Kumar K.V a A(C)critA :
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>   arch/powerpc/platforms/Kconfig.cputype | 5 +++++
>   1 file changed, 5 insertions(+)
> 
> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
> index 80175000042d..8acc4f27d101 100644
> --- a/arch/powerpc/platforms/Kconfig.cputype
> +++ b/arch/powerpc/platforms/Kconfig.cputype
> @@ -351,6 +351,11 @@ config PPC_RADIX_MMU
>   	  is only implemented by IBM Power9 CPUs, if you don't have one of them
>   	  you can probably disable this.
>   
> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	def_bool y
> +	depends on PPC_BOOK3S_64 && HUGETLB_PAGE && MIGRATION
> +
> +

Is there a reason why you redefine ARCH_ENABLE_HUGEPAGE_MIGRATION 
instead of doing a 'select' as it is already defined in mm/Kconfig ?

Christophe

>   config PPC_MMU_NOHASH
>   	def_bool y
>   	depends on !PPC_STD_MMU
> 
