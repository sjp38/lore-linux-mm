Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8F5C6B3234
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 13:22:39 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id a62so5772190oii.23
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:22:39 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t18si8801004otm.223.2018.11.23.10.22.38
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 10:22:38 -0800 (PST)
Date: Fri, 23 Nov 2018 18:22:34 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V3 5/5] arm64: mm: Allow forcing all userspace addresses
 to 52-bit
Message-ID: <20181123182233.GL3360@arrakis.emea.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-6-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114133920.7134-6-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Nov 14, 2018 at 01:39:20PM +0000, Steve Capper wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index eab02d24f5d1..17d363e40c4d 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1165,6 +1165,20 @@ config ARM64_CNP
>  	  at runtime, and does not affect PEs that do not implement
>  	  this feature.
>  
> +config ARM64_FORCE_52BIT
> +	bool "Force 52-bit virtual addresses for userspace"
> +	default n

No need for "default n"

> +	depends on ARM64_52BIT_VA && EXPERT

As long as it's for debug only and depends on EXPERT, it's fine by me.

-- 
Catalin
