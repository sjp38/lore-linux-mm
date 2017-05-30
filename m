Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F18236B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 00:26:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y65so81763564pff.13
        for <linux-mm@kvack.org>; Mon, 29 May 2017 21:26:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x13sor656849plm.2.2017.05.29.21.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 May 2017 21:26:14 -0700 (PDT)
Date: Mon, 29 May 2017 21:26:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: introduce MADV_RESET_HUGEPAGE
In-Reply-To: <1496035924-27251-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1705292125210.9353@chino.kir.corp.google.com>
References: <1496035924-27251-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, 29 May 2017, Mike Rapoport wrote:

> Currently applications can explicitly enable or disable THP for a memory
> region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> these advises is used, the region will always have
> VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> The MADV_RESET_HUGEPAGE resets both these flags and allows managing THP in
> the region according to system-wide settings.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I feel like we may be losing some information from the v1 thread regarding 
the usecase.  Would it be possible to add something to the changelog to 
describe what will use this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
