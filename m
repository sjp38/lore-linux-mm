Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id F0AED828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 05:15:41 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id g62so18004655wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:15:41 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id 134si4039764wmj.75.2016.02.18.02.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 02:15:40 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id g62so18004057wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:15:40 -0800 (PST)
Date: Thu, 18 Feb 2016 11:15:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] signals, ia64, mips: update arch-specific siginfos with
 pkeys field
Message-ID: <20160218101537.GA5540@gmail.com>
References: <20160217181703.E99B6656@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160217181703.E99B6656@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org


* Dave Hansen <dave@sr71.net> wrote:

> 
> This fixes a compile error that Ingo was hitting with MIPS when the
> x86 pkeys patch set is applied.
> 
> ia64 and mips have separate definitions for siginfo from the
> generic one.  Patch them to have the pkey fields.
> 
> Note that this is exactly what we did for MPX as well.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: linux-mips@linux-mips.org
> Cc: linux-ia64@vger.kernel.org
> ---
> 
>  b/arch/ia64/include/uapi/asm/siginfo.h |   13 +++++++++----
>  b/arch/mips/include/uapi/asm/siginfo.h |   13 +++++++++----
>  2 files changed, 18 insertions(+), 8 deletions(-)

This solved the MIPS and IA64 build problems, but there's still one bug left: UML 
does not build:

 /home/mingo/tip/mm/gup.c: In function a??check_vma_flagsa??:
 /home/mingo/tip/mm/gup.c:456:2: error: implicit declaration of function a??arch_vma_access_permitteda?? [-Werror=implicit-function-declaration]
   if (!arch_vma_access_permitted(vma, write, false, foreign))
 [...]

Please send a delta patch for this too.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
