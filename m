Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9E5A6B0005
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:14:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c23-v6so466965pfi.3
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:14:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m192-v6si1436047pga.398.2018.07.26.08.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:14:24 -0700 (PDT)
Date: Thu, 26 Jul 2018 18:14:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Message-ID: <20180726151429.yjv7l7t4a6koug5y@black.fi.intel.com>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
 <20180724121139.62570-2-kirill.shutemov@linux.intel.com>
 <20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
 <CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
 <20180724134158.676dfa7a4da16adbab3b851c@linux-foundation.org>
 <20180725123924.g2yvgie2iz2txmek@kshutemo-mobl1>
 <20180725124201.bcfec6827706fc87273f05bb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725124201.bcfec6827706fc87273f05bb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 25, 2018 at 07:42:01PM +0000, Andrew Morton wrote:
> On Wed, 25 Jul 2018 15:39:24 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > There are few more:
> > 
> > arch/arm64/include/asm/tlb.h:   struct vm_area_struct vma = { .vm_mm = tlb->mm, };
> > arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };
> > arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };
> 
> I'n not understanding.  Your "mm: use vma_init() to initialize VMAs on
> stack and data segments" addressed all those?

Yeah, sorry. Looked at wrong tree.

-- 
 Kirill A. Shutemov
