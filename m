Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC2F6B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 16:09:41 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z1-v6so12780884qtz.12
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:09:41 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h34si1223828qvc.17.2018.04.23.13.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 13:09:40 -0700 (PDT)
Date: Mon, 23 Apr 2018 16:09:30 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 10/12] arm: don't build swiotlb by default
Message-ID: <20180423200930.GB5215@char.us.oracle.com>
References: <20180423170419.20330-1-hch@lst.de>
 <20180423170419.20330-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423170419.20330-11-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, sstabellini@kernel.org
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Apr 23, 2018 at 07:04:17PM +0200, Christoph Hellwig wrote:
> swiotlb is only used as a library of helper for xen-swiotlb if Xen support
> is enabled on arm, so don't build it by default.
> 

CCing Stefano
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm/Kconfig | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index aa1c187d756d..90b81a3a28a7 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -1774,7 +1774,7 @@ config SECCOMP
>  	  defined by each seccomp mode.
>  
>  config SWIOTLB
> -	def_bool y
> +	bool
>  
>  config PARAVIRT
>  	bool "Enable paravirtualization code"
> @@ -1807,6 +1807,7 @@ config XEN
>  	depends on MMU
>  	select ARCH_DMA_ADDR_T_64BIT
>  	select ARM_PSCI
> +	select SWIOTLB
>  	select SWIOTLB_XEN
>  	select PARAVIRT
>  	help
> -- 
> 2.17.0
> 
