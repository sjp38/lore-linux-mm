Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AA4EB6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 03:29:44 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so1175330pab.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 00:29:44 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id g4si68706263pdi.65.2015.06.30.00.29.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 00:29:43 -0700 (PDT)
Message-ID: <55924508.9080101@synopsys.com>
Date: Tue, 30 Jun 2015 12:58:08 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cleaning per architecture MM hook header files
References: <1435587909-23163-1-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <1435587909-23163-1-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Monday 29 June 2015 07:55 PM, Laurent Dufour wrote:
> The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
> header file (mm-arch-hooks.h) for every architecture, even those which
> doesn't need to define mm hooks.
> 
> As suggested by Geert Uytterhoeven, this could be cleaned through the use
> of a generic header file included via each per architecture
> asm/include/Kbuild file.
> 
> The powerpc architecture is not impacted here since this architecture has
> to defined the arch_remap MM hook.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-arch@vger.kernel.org
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> ---

snipped....

> diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
> index 769b312c1abb..2febe6ff32ed 100644
> --- a/arch/arc/include/asm/Kbuild
> +++ b/arch/arc/include/asm/Kbuild
> @@ -49,3 +49,4 @@ generic-y += ucontext.h
>  generic-y += user.h
>  generic-y += vga.h
>  generic-y += xor.h
> +generic-y += mm-arch-hooks.h
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
> diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
> index 83c50193626c..870a2f7cbada 100644
> --- a/arch/arm/include/asm/Kbuild
> +++ b/arch/arm/include/asm/Kbuild
> @@ -36,3 +36,4 @@ generic-y += termios.h
>  generic-y += timex.h
>  generic-y += trace_clock.h
>  generic-y += unaligned.h
> +generic-y += mm-arch-hooks.h

We keep this file sorted by headers so please can u respin with right ordering !

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
