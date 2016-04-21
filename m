Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED35982F69
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 04:49:51 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so56452158pab.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 01:49:51 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m63si2406265pfm.104.2016.04.21.01.49.50
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 01:49:51 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:49:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] set_pte_at: racy dirty state clearing warning
Message-ID: <20160421084946.GA23774@e104818-lin.cambridge.arm.com>
References: <57180A53.3000207@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57180A53.3000207@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Apr 20, 2016 at 04:01:39PM -0700, Shi, Yang wrote:
> When I enable memory comact via
> 
> # echo 1 > /proc/sys/vm/compact_memory
> 
> I got the below WARNING:
> 
> set_pte_at: racy dirty state clearing: 0x0068000099371bd3 ->
> 0x0068000099371fd3
> ------------[ cut here ]------------
> WARNING: CPU: 5 PID: 294 at ./arch/arm64/include/asm/pgtable.h:227
> ptep_set_access_flags+0x138/0x1b8
> Modules linked in:

Do you have this patch applied:

http://article.gmane.org/gmane.linux.ports.arm.kernel/492239

It's also queued into -next as commit 66dbd6e61a52.

> My kernel has ARM64_HW_AFDBM enabled, but LS2085 is not ARMv8.1.
> 
> The code shows it just check if ARM64_HW_AFDBM is enabled or not, but
> doesn't check if the CPU really has such capability.
> 
> So, it might be better to have the capability checked runtime?

The warnings are there to spot any incorrect uses of the pte accessors
even before you run on AF/DBM-capable hardware.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
