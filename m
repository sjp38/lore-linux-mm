Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58E9D6B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 03:57:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so68601882pgc.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 00:57:25 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k71si21403460pfb.249.2016.11.14.00.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 00:57:24 -0800 (PST)
From: mpe@ellerman.id.au
Subject: Re: [PATCH V3 1/2] mm: move vma_is_anonymous check within pmd_move_must_withdraw
In-Reply-To: <20161113150025.17942-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161113150025.17942-1-aneesh.kumar@linux.vnet.ibm.com>
Date: Mon, 14 Nov 2016 19:57:16 +1100
Message-ID: <87inrqiglv.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, benh@au1.ibm.com, michael.neuling@au1.ibm.com, paulus@au1.ibm.com, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Architectures like ppc64 want to use page table deposit/withraw
> even with huge pmd dax entries. Allow arch to override the
> vma_is_anonymous check by moving that to pmd_move_must_withdraw
> function
>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h |  3 ++-
>  include/asm-generic/pgtable.h                | 12 ------------
>  mm/huge_memory.c                             | 18 ++++++++++++++++--
>  3 files changed, 18 insertions(+), 15 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
