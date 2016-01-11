Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 70535828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:04:41 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id f206so217676640wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:04:41 -0800 (PST)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id 14si23965620wmq.78.2016.01.11.08.04.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 08:04:40 -0800 (PST)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 11 Jan 2016 16:04:39 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id A09C51B08074
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:04:38 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0BG4b0m8192368
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:04:37 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0BG4aSn007713
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:04:36 -0500
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking
 swapoff
References: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Message-ID: <5693D292.7020603@linux.vnet.ibm.com>
Date: Mon, 11 Jan 2016 17:04:34 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 10/01/2016 01:54, Hugh Dickins wrote:
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

Acked-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Thanks, Hugh!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
