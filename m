Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CCA4B6B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 07:12:07 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id rd3so3510823pab.16
        for <linux-mm@kvack.org>; Thu, 01 May 2014 04:12:07 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id hi3si20364462pac.369.2014.05.01.04.12.05
        for <linux-mm@kvack.org>;
        Thu, 01 May 2014 04:12:06 -0700 (PDT)
Date: Thu, 1 May 2014 12:11:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH V4 3/7] arm: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140501111120.GF22316@arm.com>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
 <1396018892-6773-4-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396018892-6773-4-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Mar 28, 2014 at 03:01:28PM +0000, Steve Capper wrote:
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 1594945..7d5340d 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -58,6 +58,7 @@ config ARM
>  	select HAVE_PERF_EVENTS
>  	select HAVE_PERF_REGS
>  	select HAVE_PERF_USER_STACK_DUMP
> +	select HAVE_RCU_TABLE_FREE if SMP

You select this if (SMP && CPU_V7). On ARMv6 SMP systems we use IPI for
TLB maintenance already.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
