Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 69EE9828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 09:07:44 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id bc4so241923438lbc.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:07:44 -0800 (PST)
Received: from mail-lb0-x244.google.com (mail-lb0-x244.google.com. [2a00:1450:4010:c04::244])
        by mx.google.com with ESMTPS id e193si50868926lfd.173.2016.01.10.06.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 06:07:43 -0800 (PST)
Received: by mail-lb0-x244.google.com with SMTP id ti8so24209433lbb.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:07:42 -0800 (PST)
Date: Sun, 10 Jan 2016 17:07:40 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking
 swapoff
Message-ID: <20160110140740.GB4306@uranus>
References: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Sat, Jan 09, 2016 at 04:54:59PM -0800, Hugh Dickins wrote:
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
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thank you, Hugh!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
