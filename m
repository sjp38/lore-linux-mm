Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E671C6B0006
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:49:41 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 91-v6so800595pla.18
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:49:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i63si539807pfk.159.2018.04.11.01.49.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 01:49:41 -0700 (PDT)
Date: Wed, 11 Apr 2018 10:49:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/2] mm: remove odd HAVE_PTE_SPECIAL
Message-ID: <20180411084936.GC23400@dhcp22.suse.cz>
References: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523433816-14460-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180411083315.GA23400@dhcp22.suse.cz>
 <5bd1bb46-8f71-e6db-7fb7-43d023a37f58@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5bd1bb46-8f71-e6db-7fb7-43d023a37f58@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>

On Wed 11-04-18 10:41:23, Laurent Dufour wrote:
> On 11/04/2018 10:33, Michal Hocko wrote:
> > On Wed 11-04-18 10:03:36, Laurent Dufour wrote:
> >> @@ -881,7 +876,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> >>  
> >>  	if (is_zero_pfn(pfn))
> >>  		return NULL;
> >> -check_pfn:
> >> +
> >> +check_pfn: __maybe_unused
> >>  	if (unlikely(pfn > highest_memmap_pfn)) {
> >>  		print_bad_pte(vma, addr, pte, NULL);
> >>  		return NULL;
> >> @@ -891,7 +887,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> >>  	 * NOTE! We still have PageReserved() pages in the page tables.
> >>  	 * eg. VDSO mappings can cause them to exist.
> >>  	 */
> >> -out:
> >> +out: __maybe_unused
> >>  	return pfn_to_page(pfn);
> > 
> > Why do we need this ugliness all of the sudden?
> Indeed the compiler doesn't complaint but in theory it should since these
> labels are not used depending on CONFIG_ARCH_HAS_PTE_SPECIAL.

Well, such a warning would be quite pointless so I would rather not make
the code ugly. The value of unused label is quite questionable to start
with...

-- 
Michal Hocko
SUSE Labs
