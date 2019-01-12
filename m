Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10A308E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 10:49:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so10191088pls.21
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 07:49:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 193si14797096pfa.256.2019.01.12.07.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 12 Jan 2019 07:49:56 -0800 (PST)
Date: Sat, 12 Jan 2019 07:49:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
Message-ID: <20190112154944.GT6310@bombadil.infradead.org>
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <20190112121230.GQ6310@bombadil.infradead.org>
 <ddd59fdc-3d8f-4015-e851-e7f099193a1b@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddd59fdc-3d8f-4015-e851-e7f099193a1b@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, mark.rutland@arm.com, mhocko@suse.com, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, mingo@redhat.com, vbabka@suse.cz, rientjes@google.com, marc.zyngier@arm.com, rppt@linux.vnet.ibm.com, shakeelb@google.com, kirill@shutemov.name, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, steve.capper@arm.com, christoffer.dall@arm.com, james.morse@arm.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org

On Sat, Jan 12, 2019 at 02:49:29PM +0100, Christophe Leroy wrote:
> As far as I can see,
> 
> #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
> 
> So what's the difference between:
> 
> (GFP_KERNEL_ACCOUNT | __GFP_ZERO) & ~__GFP_ACCOUNT
> 
> and
> 
> (GFP_KERNEL | __GFP_ZERO) & ~__GFP_ACCOUNT

Nothing.  But there's a huge difference in the other parts of that same
file where GFP_ACCOUNT is _not_ used.

I think this unification is too small to bother with.  Something I've
had on my todo list for some time and have not done anything about
is to actually unify all of the architecture pte/pmd/... allocations.
There are tricks some architectures use that others would benefit from.
