Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5746B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 10:29:02 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so379123pad.37
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:29:01 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id rt2si1091577pbc.18.2014.08.27.07.28.54
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 07:28:54 -0700 (PDT)
Date: Wed, 27 Aug 2014 15:28:01 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATH V2 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20140827142801.GA13850@arm.com>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, Aug 21, 2014 at 04:43:27PM +0100, Steve Capper wrote:
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 886db21..6a4d764 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config HAVE_MEMBLOCK_PHYS_MAP
>  	boolean
>  
> +config HAVE_RCU_GUP
> +	boolean

Minor detail, maybe HAVE_GENERIC_RCU_GUP to avoid confusion.

Otherwise the patch looks fine to me.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
