Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F410C6B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 00:04:04 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so27840794pab.19
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 21:04:04 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id a10si37266635pat.37.2015.01.04.21.04.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jan 2015 21:04:03 -0800 (PST)
Message-ID: <1420434223.3860.1.camel@ellerman.id.au>
Subject: Re: [PATCH 29/38] powerpc: drop _PAGE_FILE and pte_file()-related
 helpers
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 05 Jan 2015 16:03:43 +1100
In-Reply-To: <1419423766-114457-30-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1419423766-114457-30-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On Wed, 2014-12-24 at 14:22 +0200, Kirill A. Shutemov wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  arch/powerpc/include/asm/pgtable-ppc32.h | 9 ++-------
>  arch/powerpc/include/asm/pgtable-ppc64.h | 5 +----
>  arch/powerpc/include/asm/pgtable.h       | 1 -
>  arch/powerpc/include/asm/pte-40x.h       | 1 -
>  arch/powerpc/include/asm/pte-44x.h       | 5 -----
>  arch/powerpc/include/asm/pte-8xx.h       | 1 -
>  arch/powerpc/include/asm/pte-book3e.h    | 1 -
>  arch/powerpc/include/asm/pte-fsl-booke.h | 3 ---
>  arch/powerpc/include/asm/pte-hash32.h    | 1 -
>  arch/powerpc/include/asm/pte-hash64.h    | 1 -
>  arch/powerpc/mm/pgtable_64.c             | 2 +-
>  11 files changed, 4 insertions(+), 26 deletions(-)

These bits look fine to me.

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
