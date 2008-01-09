Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m09HVdS0086562
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 17:31:39 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09HVcPO2764808
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 18:31:39 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09HVc1I030240
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 18:31:38 +0100
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference
	counting for VM_MIXEDMAP pages
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com>  <20071221104701.GE28484@wotan.suse.de>
	 <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
	 <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com>
	 <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Wed, 09 Jan 2008 18:31:45 +0100
Message-Id: <1199899905.25572.0.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-09 at 16:14 +0100, Carsten Otte wrote:
> include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
> 
> This patch introduces two arch callbacks, which may optionally be implemented
> in case the architecutre does define __HAVE_ARCH_PTEP_NOREFCOUNT.
> 
> The first callback, pte_set_norefcount(__pte) is called by core-vm to indicate
> that subject page table entry is going to be inserted into a VM_MIXEDMAP vma.
> default implementation: 	noop
> s390 implementation:		set sw defined bit in pte
> proposed arm implementation:	noop
> 
> The second callback, mixedmap_refcount_pte(__pte) is called by core-vm to
> figure out whether or not subject pte requires reference counting in the
> corresponding struct page entry. A non-zero result indicates reference counting
> is required.
> default implementation:		(1)
> s390 implementation:		query sw defined bit in pte
> proposed arm implementation:	convert pte_t to pfn, use pfn_valid()
> 
> Signed-off-by: Carsten Otte <cotte@de.ibm.com>

For the s390 pieces of this patch:

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
