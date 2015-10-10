Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 89C606B0038
	for <linux-mm@kvack.org>; Sat, 10 Oct 2015 11:34:57 -0400 (EDT)
Received: by lbos8 with SMTP id s8so106574590lbo.0
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 08:34:55 -0700 (PDT)
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com. [209.85.217.179])
        by mx.google.com with ESMTPS id i82si4766414lfb.12.2015.10.10.08.34.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Oct 2015 08:34:54 -0700 (PDT)
Received: by lbwr8 with SMTP id r8so106930997lbw.2
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 08:34:54 -0700 (PDT)
Date: Sat, 10 Oct 2015 17:35:11 +0200
From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: Re: [PATCH v2 11/20] kvm: rename pfn_t to kvm_pfn_t
Message-ID: <20151010153511.GG29128@cbox>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
 <20151010005622.17221.44373.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151010005622.17221.44373.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Dave Hansen <dave@sr71.net>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, ross.zwisler@linux.intel.com, hch@lst.de, Alexander Graf <agraf@suse.com>

On Fri, Oct 09, 2015 at 08:56:22PM -0400, Dan Williams wrote:
> The core has developed a need for a "pfn_t" type [1].  Move the existing
> pfn_t in KVM to kvm_pfn_t [2].
> 
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html
> [2]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002218.html
> 
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Gleb Natapov <gleb@kernel.org>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Christoffer Dall <christoffer.dall@linaro.org>
> Cc: Marc Zyngier <marc.zyngier@arm.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Alexander Graf <agraf@suse.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/arm/include/asm/kvm_mmu.h        |    5 ++--
>  arch/arm/kvm/mmu.c                    |   10 ++++---
>  arch/arm64/include/asm/kvm_mmu.h      |    3 +-
>  arch/mips/include/asm/kvm_host.h      |    6 ++--
>  arch/mips/kvm/emulate.c               |    2 +
>  arch/mips/kvm/tlb.c                   |   14 +++++-----
>  arch/powerpc/include/asm/kvm_book3s.h |    4 +--
>  arch/powerpc/include/asm/kvm_ppc.h    |    2 +
>  arch/powerpc/kvm/book3s.c             |    6 ++--
>  arch/powerpc/kvm/book3s_32_mmu_host.c |    2 +
>  arch/powerpc/kvm/book3s_64_mmu_host.c |    2 +
>  arch/powerpc/kvm/e500.h               |    2 +
>  arch/powerpc/kvm/e500_mmu_host.c      |    8 +++---
>  arch/powerpc/kvm/trace_pr.h           |    2 +
>  arch/x86/kvm/iommu.c                  |   11 ++++----
>  arch/x86/kvm/mmu.c                    |   37 +++++++++++++-------------
>  arch/x86/kvm/mmu_audit.c              |    2 +
>  arch/x86/kvm/paging_tmpl.h            |    6 ++--
>  arch/x86/kvm/vmx.c                    |    2 +
>  arch/x86/kvm/x86.c                    |    2 +
>  include/linux/kvm_host.h              |   37 +++++++++++++-------------
>  include/linux/kvm_types.h             |    2 +
>  virt/kvm/kvm_main.c                   |   47 +++++++++++++++++----------------
>  23 files changed, 110 insertions(+), 104 deletions(-)
> 
> diff --git a/arch/arm/include/asm/kvm_mmu.h b/arch/arm/include/asm/kvm_mmu.h
> index 405aa1883307..8ebd282dfc2b 100644
> --- a/arch/arm/include/asm/kvm_mmu.h
> +++ b/arch/arm/include/asm/kvm_mmu.h
> @@ -182,7 +182,8 @@ static inline bool vcpu_has_cache_enabled(struct kvm_vcpu *vcpu)
>  	return (vcpu->arch.cp15[c1_SCTLR] & 0b101) == 0b101;
>  }
>  
> -static inline void __coherent_cache_guest_page(struct kvm_vcpu *vcpu, pfn_t pfn,
> +static inline void __coherent_cache_guest_page(struct kvm_vcpu *vcpu,
> +					       kvm_pfn_t pfn,
>  					       unsigned long size,
>  					       bool ipa_uncached)
>  {
> @@ -246,7 +247,7 @@ static inline void __kvm_flush_dcache_pte(pte_t pte)
>  static inline void __kvm_flush_dcache_pmd(pmd_t pmd)
>  {
>  	unsigned long size = PMD_SIZE;
> -	pfn_t pfn = pmd_pfn(pmd);
> +	kvm_pfn_t pfn = pmd_pfn(pmd);
>  
>  	while (size) {
>  		void *va = kmap_atomic_pfn(pfn);
> diff --git a/arch/arm/kvm/mmu.c b/arch/arm/kvm/mmu.c
> index 6984342da13d..e2dcbfdc4a8c 100644
> --- a/arch/arm/kvm/mmu.c
> +++ b/arch/arm/kvm/mmu.c
> @@ -988,9 +988,9 @@ out:
>  	return ret;
>  }
>  
> -static bool transparent_hugepage_adjust(pfn_t *pfnp, phys_addr_t *ipap)
> +static bool transparent_hugepage_adjust(kvm_pfn_t *pfnp, phys_addr_t *ipap)
>  {
> -	pfn_t pfn = *pfnp;
> +	kvm_pfn_t pfn = *pfnp;
>  	gfn_t gfn = *ipap >> PAGE_SHIFT;
>  
>  	if (PageTransCompound(pfn_to_page(pfn))) {
> @@ -1202,7 +1202,7 @@ void kvm_arch_mmu_enable_log_dirty_pt_masked(struct kvm *kvm,
>  	kvm_mmu_write_protect_pt_masked(kvm, slot, gfn_offset, mask);
>  }
>  
> -static void coherent_cache_guest_page(struct kvm_vcpu *vcpu, pfn_t pfn,
> +static void coherent_cache_guest_page(struct kvm_vcpu *vcpu, kvm_pfn_t pfn,
>  				      unsigned long size, bool uncached)
>  {
>  	__coherent_cache_guest_page(vcpu, pfn, size, uncached);
> @@ -1219,7 +1219,7 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
>  	struct kvm *kvm = vcpu->kvm;
>  	struct kvm_mmu_memory_cache *memcache = &vcpu->arch.mmu_page_cache;
>  	struct vm_area_struct *vma;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	pgprot_t mem_type = PAGE_S2;
>  	bool fault_ipa_uncached;
>  	bool logging_active = memslot_is_logging(memslot);
> @@ -1347,7 +1347,7 @@ static void handle_access_fault(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa)
>  {
>  	pmd_t *pmd;
>  	pte_t *pte;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	bool pfn_valid = false;
>  
>  	trace_kvm_access_fault(fault_ipa);
> diff --git a/arch/arm64/include/asm/kvm_mmu.h b/arch/arm64/include/asm/kvm_mmu.h
> index 61505676d085..385fc8cef82d 100644
> --- a/arch/arm64/include/asm/kvm_mmu.h
> +++ b/arch/arm64/include/asm/kvm_mmu.h
> @@ -230,7 +230,8 @@ static inline bool vcpu_has_cache_enabled(struct kvm_vcpu *vcpu)
>  	return (vcpu_sys_reg(vcpu, SCTLR_EL1) & 0b101) == 0b101;
>  }
>  
> -static inline void __coherent_cache_guest_page(struct kvm_vcpu *vcpu, pfn_t pfn,
> +static inline void __coherent_cache_guest_page(struct kvm_vcpu *vcpu,
> +					       kvm_pfn_t pfn,
>  					       unsigned long size,
>  					       bool ipa_uncached)
>  {
[...]

For the arm/arm64 part:
Acked-by: Christoffer Dall <christoffer.dall@linaro.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
