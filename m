Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1294F4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:32:54 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z14so124304327igp.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:32:54 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x1si33049728igl.76.2016.01.12.04.32.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 04:32:53 -0800 (PST)
In-Reply-To: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking swapoff
Message-Id: <20160112123249.98EBF140A98@ozlabs.org>
Date: Tue, 12 Jan 2016 23:32:49 +1100 (AEDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On Sun, 2016-10-01 at 00:54:59 UTC, Hugh Dickins wrote:
> Swapoff after swapping hangs on the G5, when CONFIG_CHECKPOINT_RESTORE=y
> but CONFIG_MEM_SOFT_DIRTY is not set.  That's because the non-zero
> _PAGE_SWP_SOFT_DIRTY bit, added by CONFIG_HAVE_ARCH_SOFT_DIRTY=y, is not
> discounted when CONFIG_MEM_SOFT_DIRTY is not set: so swap ptes cannot be
> recognized.
> 
> (I suspect that the peculiar dependence of HAVE_ARCH_SOFT_DIRTY on
> CHECKPOINT_RESTORE in arch/powerpc/Kconfig comes from an incomplete
> attempt to solve this problem.)
> 
> It's true that the relationship between CONFIG_HAVE_ARCH_SOFT_DIRTY and
> and CONFIG_MEM_SOFT_DIRTY is too confusing, and it's true that swapoff
> should be made more robust; but nevertheless, fix up the powerpc ifdefs
> as x86_64 and s390 (which met the same problem) have them, defining the
> bits as 0 if CONFIG_MEM_SOFT_DIRTY is not set.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Acked-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/2f10f1a7884e97a68e52c4b6f7

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
