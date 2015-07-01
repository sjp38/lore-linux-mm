Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 30DE96B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 08:52:14 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so23291860pac.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 05:52:13 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id ri10si3328390pdb.167.2015.07.01.05.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 05:52:13 -0700 (PDT)
Message-ID: <5593E23A.4010709@synopsys.com>
Date: Wed, 1 Jul 2015 18:21:06 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: cleaning per architecture MM hook header files
References: <55924508.9080101@synopsys.com> <1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: uclinux-h8-devel@lists.sourceforge.jp, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wednesday 01 July 2015 03:47 PM, Laurent Dufour wrote:
> The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
> header file (mm-arch-hooks.h) for every architecture, even those which
> doesn't need to define mm hooks.
> 
> As suggested by Geert Uytterhoeven, this could be cleaned through the use
> of a generic header file included via each per architecture
> asm/include/Kbuild file.
> 
> The PowerPC architecture is not impacted here since this architecture has
> to defined the arch_remap MM hook.
> 
> Changes in V2:
> --------------
>  - Vineet Gupta reported that the Kbuild files should be kept sorted.
>  - Add fix for the newly introduced H8/300 architecture.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Vineet Gupta <Vineet.Gupta1@synopsys.com>
.
[snip]

> diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
> index 769b312c1abb..f2a3cdfee5f5 100644
> --- a/arch/arc/include/asm/Kbuild
> +++ b/arch/arc/include/asm/Kbuild
> @@ -23,6 +23,7 @@ generic-y += kvm_para.h
>  generic-y += local.h
>  generic-y += local64.h
>  generic-y += mcs_spinlock.h
> +generic-y += mm-arch-hooks.h
>  generic-y += mman.h
>  generic-y += msgbuf.h
>  generic-y += param.h
> diff --git a/arch/arc/include/asm/mm-arch-hooks.h b/arch/arc/include/asm/mm-arch-hooks.h
> deleted file mode 100644
> index c37541c5f8ba..000000000000
> --- a/arch/arc/include/asm/mm-arch-hooks.h
> +++ /dev/null
> @@ -1,15 +0,0 @@
> -/*
> - * Architecture specific mm hooks
> - *
> - * Copyright (C) 2015, IBM Corporation
> - * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -
> -#ifndef _ASM_ARC_MM_ARCH_HOOKS_H
> -#define _ASM_ARC_MM_ARCH_HOOKS_H
> -
> -#endif /* _ASM_ARC_MM_ARCH_HOOKS_H */

Acked-by: Vineet Gupta <vgupta@synopsys.com>   # for arch/arc

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
