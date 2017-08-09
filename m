Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89FA86B02F4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 06:12:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v31so8211682wrc.7
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:12:44 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j18si3898123edh.26.2017.08.09.03.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 03:12:43 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id q189so6224970wmd.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:12:43 -0700 (PDT)
Date: Wed, 9 Aug 2017 13:12:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/16] mm: Protect VMA modifications using VMA sequence
 count
Message-ID: <20170809101241.ek4fqinqaq5qfkq4@node.shutemov.name>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-6-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502202949-8138-6-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Aug 08, 2017 at 04:35:38PM +0200, Laurent Dufour wrote:
> The VMA sequence count has been introduced to allow fast detection of
> VMA modification when running a page fault handler without holding
> the mmap_sem.
> 
> This patch provides protection agains the VMA modification done in :
> 	- madvise()
> 	- mremap()
> 	- mpol_rebind_policy()
> 	- vma_replace_policy()
> 	- change_prot_numa()
> 	- mlock(), munlock()
> 	- mprotect()
> 	- mmap_region()
> 	- collapse_huge_page()

I don't thinks it's anywhere near complete list of places where we touch
vm_flags. What is your plan for the rest?
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
