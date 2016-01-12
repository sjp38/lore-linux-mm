Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 454234403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:32:53 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id z14so124304074igp.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:32:53 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id ug8si33033508igb.47.2016.01.12.04.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 04:32:52 -0800 (PST)
In-Reply-To: <1452527374-4886-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [V2] mm/powerpc: Fix _PAGE_PTE breaking swapoff
Message-Id: <20160112123248.B9056140B96@ozlabs.org>
Date: Tue, 12 Jan 2016 23:32:48 +1100 (AEDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, 2016-11-01 at 15:49:34 UTC, "Aneesh Kumar K.V" wrote:
> Core kernel expect swp_entry_t to be consisting of
> only swap type and swap offset. We should not leak pte bits to
> swp_entry_t. This breaks swapoff which use the swap type and offset
> to build a swp_entry_t and later compare that to the swp_entry_t
> obtained from linux page table pte. Leaking pte bits to swp_entry_t
> breaks that comparison and results in us looping in try_to_unuse.
> 
> The stack trace can be anywhere below try_to_unuse() in mm/swapfile.c,
> since swapoff is circling around and around that function, reading from
> each used swap block into a page, then trying to find where that page
> belongs, looking at every non-file pte of every mm that ever swapped.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Suggested-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Hugh Dickins <hughd@google.com>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/44734f23de2465c3c0d39e4a16

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
