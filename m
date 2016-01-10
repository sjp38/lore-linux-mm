Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 088A4828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 09:09:07 -0500 (EST)
Received: by mail-lf0-f49.google.com with SMTP id h129so4544401lfh.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:09:06 -0800 (PST)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id t4si3474931lbr.207.2016.01.10.06.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 06:09:05 -0800 (PST)
Received: by mail-lb0-x243.google.com with SMTP id jk7so19982938lbc.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:09:05 -0800 (PST)
Date: Sun, 10 Jan 2016 17:09:02 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH next] mm: make swapoff more robust against soft dirty
Message-ID: <20160110140902.GA31017@uranus>
References: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
 <alpine.LSU.2.11.1601091656491.9808@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1601091656491.9808@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Sat, Jan 09, 2016 at 04:59:42PM -0800, Hugh Dickins wrote:
> Both s390 and powerpc have hit the issue of swapoff hanging, when
> CONFIG_HAVE_ARCH_SOFT_DIRTY and CONFIG_MEM_SOFT_DIRTY ifdefs were
> not quite as x86_64 had them.  I think it would be much clearer if
> HAVE_ARCH_SOFT_DIRTY was just a Kconfig option set by architectures
> to determine whether the MEM_SOFT_DIRTY option should be offered,
> and the actual code depend upon CONFIG_MEM_SOFT_DIRTY alone.
> 
> But won't embark on that change myself: instead make swapoff more
> robust, by using pte_swp_clear_soft_dirty() on each pte it encounters,
> without an explicit #ifdef CONFIG_MEM_SOFT_DIRTY.  That being a no-op,
> whether the bit in question is defined as 0 or the asm-generic fallback
> is used, unless soft dirty is fully turned on.
> 
> Why "maybe" in maybe_same_pte()?  Rename it pte_same_as_swp().
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thanks a lot, Hugh!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
