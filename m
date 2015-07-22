Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCAB6B0256
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:24:16 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so68618134pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:24:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i3si4266016pdp.75.2015.07.22.07.24.15
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:24:15 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:24:10 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 3/5] arm64: move PGD_SIZE definition to pgalloc.h
Message-ID: <20150722142410.GC16627@e104818-lin.cambridge.arm.com>
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
 <1437561037-31995-4-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437561037-31995-4-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jul 22, 2015 at 01:30:35PM +0300, Andrey Ryabinin wrote:
> This will be used by KASAN latter.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
