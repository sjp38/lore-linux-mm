Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59B5F6B0007
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:33:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s6so358305pgn.16
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:33:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si512957pfc.409.2018.04.11.01.33.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 01:33:20 -0700 (PDT)
Date: Wed, 11 Apr 2018 10:33:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/2] mm: remove odd HAVE_PTE_SPECIAL
Message-ID: <20180411083315.GA23400@dhcp22.suse.cz>
References: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523433816-14460-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523433816-14460-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>

On Wed 11-04-18 10:03:36, Laurent Dufour wrote:
> @@ -881,7 +876,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	if (is_zero_pfn(pfn))
>  		return NULL;
> -check_pfn:
> +
> +check_pfn: __maybe_unused
>  	if (unlikely(pfn > highest_memmap_pfn)) {
>  		print_bad_pte(vma, addr, pte, NULL);
>  		return NULL;
> @@ -891,7 +887,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  	 * NOTE! We still have PageReserved() pages in the page tables.
>  	 * eg. VDSO mappings can cause them to exist.
>  	 */
> -out:
> +out: __maybe_unused
>  	return pfn_to_page(pfn);

Why do we need this ugliness all of the sudden?

-- 
Michal Hocko
SUSE Labs
