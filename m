Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 500136B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:26:49 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so80639335pac.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:26:49 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a68si49121309pfb.39.2016.08.10.09.26.48
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 09:26:48 -0700 (PDT)
Message-ID: <57AB55C4.1070200@arm.com>
Date: Wed, 10 Aug 2016 17:26:44 +0100
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v24 2/9] memblock: add memblock_cap_memory_range()
References: <20160809015248.28414-2-takahiro.akashi@linaro.org> <20160809015526.28479-1-takahiro.akashi@linaro.org>
In-Reply-To: <20160809015526.28479-1-takahiro.akashi@linaro.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AKASHI Takahiro <takahiro.akashi@linaro.org>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Hi Akashi,

On 09/08/16 02:55, AKASHI Takahiro wrote:
> Crash dump kernel uses only a limited range of memory as System RAM.
> On arm64 implementation, a new device tree property,
> "linux,usable-memory-range," is used to notify crash dump kernel of
> this range.[1]
> But simply excluding all the other regions, whatever their memory types
> are, doesn't work, especially, on the systems with ACPI. Since some of
> such regions will be later mapped as "device memory" by ioremap()/
> acpi_os_ioremap(), it can cause errors like unalignment accesses.[2]
> This issue is akin to the one reported in [3].
> 
> So this patch follows Chen's approach, and implements a new function,
> memblock_cap_memory_range(), which will exclude only the memory regions
> that are not marked "NOMAP" from memblock.memory.

This (and the next patch) fixes the acpi related unaligned access problem I had.
I've tested it on a Juno r1 and Seattle B0.

Tested-by: James Morse <james.morse@arm.com>


Thanks,

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
