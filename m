Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 011E86B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:57:19 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id w61so2803796wes.23
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 06:57:18 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id h9si12018783wiz.69.2014.07.24.06.57.11
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 06:57:12 -0700 (PDT)
Date: Thu, 24 Jul 2014 14:56:40 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 0/5] Atomic pool for arm64
Message-ID: <20140724135640.GD13371@arm.com>
References: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Wed, Jul 23, 2014 at 02:35:03AM +0100, Laura Abbott wrote:
> Laura Abbott (5):
>   lib/genalloc.c: Add power aligned algorithm
>   lib/genalloc.c: Add genpool range check function
>   common: dma-mapping: Introduce common remapping functions
>   arm: use genalloc for the atomic pool
>   arm64: Add atomic pool for non-coherent and CMA allocations.

The only thing left is the removal of unmap_kernel_range() call in
dma_common_free_remap() (vunmap is enough). Feel free to add my review
to the whole series:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
