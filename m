Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA9B6B0038
	for <linux-mm@kvack.org>; Sat, 10 Oct 2015 16:36:04 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so109461753wic.0
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 13:36:03 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id cn7si6163939wib.42.2015.10.10.13.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Oct 2015 13:36:02 -0700 (PDT)
Received: by wijq8 with SMTP id q8so9048777wij.0
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 13:36:02 -0700 (PDT)
Subject: Re: [PATCH v2 11/20] kvm: rename pfn_t to kvm_pfn_t
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
 <20151010005622.17221.44373.stgit@dwillia2-desk3.jf.intel.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <561976AC.6000003@redhat.com>
Date: Sat, 10 Oct 2015 22:35:56 +0200
MIME-Version: 1.0
In-Reply-To: <20151010005622.17221.44373.stgit@dwillia2-desk3.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>, Christoffer Dall <christoffer.dall@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, ross.zwisler@linux.intel.com, hch@lst.de, Alexander Graf <agraf@suse.com>

On 10/10/2015 02:56, Dan Williams wrote:
> The core has developed a need for a "pfn_t" type [1].  Move the existing
> pfn_t in KVM to kvm_pfn_t [2].
> 
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html
> [2]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002218.html

Can you please change also the other types in include/linux/kvm_types.h?

Thanks,

Paolo

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
> diff --git a/arch/mips/include/asm/kvm_host.h b/arch/mips/include/asm/kvm_host.h
> index 5a1a882e0a75..9c67f05a0a1b 100644
> --- a/arch/mips/include/asm/kvm_host.h
> +++ b/arch/mips/include/asm/kvm_host.h
> @@ -101,9 +101,9 @@
>  #define CAUSEF_DC			(_ULCAST_(1) << 27)
>  
>  extern atomic_t kvm_mips_instance;
> -extern pfn_t(*kvm_mips_gfn_to_pfn) (struct kvm *kvm, gfn_t gfn);
> -extern void (*kvm_mips_release_pfn_clean) (pfn_t pfn);
> -extern bool(*kvm_mips_is_error_pfn) (pfn_t pfn);
> +extern kvm_pfn_t (*kvm_mips_gfn_to_pfn)(struct kvm *kvm, gfn_t gfn);
> +extern void (*kvm_mips_release_pfn_clean)(kvm_pfn_t pfn);
> +extern bool (*kvm_mips_is_error_pfn)(kvm_pfn_t pfn);
>  
>  struct kvm_vm_stat {
>  	u32 remote_tlb_flush;
> diff --git a/arch/mips/kvm/emulate.c b/arch/mips/kvm/emulate.c
> index d5fa3eaf39a1..476296cf37d3 100644
> --- a/arch/mips/kvm/emulate.c
> +++ b/arch/mips/kvm/emulate.c
> @@ -1525,7 +1525,7 @@ int kvm_mips_sync_icache(unsigned long va, struct kvm_vcpu *vcpu)
>  	struct kvm *kvm = vcpu->kvm;
>  	unsigned long pa;
>  	gfn_t gfn;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	gfn = va >> PAGE_SHIFT;
>  
> diff --git a/arch/mips/kvm/tlb.c b/arch/mips/kvm/tlb.c
> index aed0ac2a4972..570479c03bdc 100644
> --- a/arch/mips/kvm/tlb.c
> +++ b/arch/mips/kvm/tlb.c
> @@ -38,13 +38,13 @@ atomic_t kvm_mips_instance;
>  EXPORT_SYMBOL(kvm_mips_instance);
>  
>  /* These function pointers are initialized once the KVM module is loaded */
> -pfn_t (*kvm_mips_gfn_to_pfn)(struct kvm *kvm, gfn_t gfn);
> +kvm_pfn_t (*kvm_mips_gfn_to_pfn)(struct kvm *kvm, gfn_t gfn);
>  EXPORT_SYMBOL(kvm_mips_gfn_to_pfn);
>  
> -void (*kvm_mips_release_pfn_clean)(pfn_t pfn);
> +void (*kvm_mips_release_pfn_clean)(kvm_pfn_t pfn);
>  EXPORT_SYMBOL(kvm_mips_release_pfn_clean);
>  
> -bool (*kvm_mips_is_error_pfn)(pfn_t pfn);
> +bool (*kvm_mips_is_error_pfn)(kvm_pfn_t pfn);
>  EXPORT_SYMBOL(kvm_mips_is_error_pfn);
>  
>  uint32_t kvm_mips_get_kernel_asid(struct kvm_vcpu *vcpu)
> @@ -144,7 +144,7 @@ EXPORT_SYMBOL(kvm_mips_dump_guest_tlbs);
>  static int kvm_mips_map_page(struct kvm *kvm, gfn_t gfn)
>  {
>  	int srcu_idx, err = 0;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	if (kvm->arch.guest_pmap[gfn] != KVM_INVALID_PAGE)
>  		return 0;
> @@ -262,7 +262,7 @@ int kvm_mips_handle_kseg0_tlb_fault(unsigned long badvaddr,
>  				    struct kvm_vcpu *vcpu)
>  {
>  	gfn_t gfn;
> -	pfn_t pfn0, pfn1;
> +	kvm_pfn_t pfn0, pfn1;
>  	unsigned long vaddr = 0;
>  	unsigned long entryhi = 0, entrylo0 = 0, entrylo1 = 0;
>  	int even;
> @@ -313,7 +313,7 @@ EXPORT_SYMBOL(kvm_mips_handle_kseg0_tlb_fault);
>  int kvm_mips_handle_commpage_tlb_fault(unsigned long badvaddr,
>  	struct kvm_vcpu *vcpu)
>  {
> -	pfn_t pfn0, pfn1;
> +	kvm_pfn_t pfn0, pfn1;
>  	unsigned long flags, old_entryhi = 0, vaddr = 0;
>  	unsigned long entrylo0 = 0, entrylo1 = 0;
>  
> @@ -360,7 +360,7 @@ int kvm_mips_handle_mapped_seg_tlb_fault(struct kvm_vcpu *vcpu,
>  {
>  	unsigned long entryhi = 0, entrylo0 = 0, entrylo1 = 0;
>  	struct kvm *kvm = vcpu->kvm;
> -	pfn_t pfn0, pfn1;
> +	kvm_pfn_t pfn0, pfn1;
>  
>  	if ((tlb->tlb_hi & VPN2_MASK) == 0) {
>  		pfn0 = 0;
> diff --git a/arch/powerpc/include/asm/kvm_book3s.h b/arch/powerpc/include/asm/kvm_book3s.h
> index 9fac01cb89c1..8f39796c9da8 100644
> --- a/arch/powerpc/include/asm/kvm_book3s.h
> +++ b/arch/powerpc/include/asm/kvm_book3s.h
> @@ -154,8 +154,8 @@ extern void kvmppc_set_bat(struct kvm_vcpu *vcpu, struct kvmppc_bat *bat,
>  			   bool upper, u32 val);
>  extern void kvmppc_giveup_ext(struct kvm_vcpu *vcpu, ulong msr);
>  extern int kvmppc_emulate_paired_single(struct kvm_run *run, struct kvm_vcpu *vcpu);
> -extern pfn_t kvmppc_gpa_to_pfn(struct kvm_vcpu *vcpu, gpa_t gpa, bool writing,
> -			bool *writable);
> +extern kvm_pfn_t kvmppc_gpa_to_pfn(struct kvm_vcpu *vcpu, gpa_t gpa,
> +			bool writing, bool *writable);
>  extern void kvmppc_add_revmap_chain(struct kvm *kvm, struct revmap_entry *rev,
>  			unsigned long *rmap, long pte_index, int realmode);
>  extern void kvmppc_update_rmap_change(unsigned long *rmap, unsigned long psize);
> diff --git a/arch/powerpc/include/asm/kvm_ppc.h b/arch/powerpc/include/asm/kvm_ppc.h
> index c6ef05bd0765..2241d5357129 100644
> --- a/arch/powerpc/include/asm/kvm_ppc.h
> +++ b/arch/powerpc/include/asm/kvm_ppc.h
> @@ -515,7 +515,7 @@ void kvmppc_claim_lpid(long lpid);
>  void kvmppc_free_lpid(long lpid);
>  void kvmppc_init_lpid(unsigned long nr_lpids);
>  
> -static inline void kvmppc_mmu_flush_icache(pfn_t pfn)
> +static inline void kvmppc_mmu_flush_icache(kvm_pfn_t pfn)
>  {
>  	struct page *page;
>  	/*
> diff --git a/arch/powerpc/kvm/book3s.c b/arch/powerpc/kvm/book3s.c
> index 099c79d8c160..638c6d9be9e0 100644
> --- a/arch/powerpc/kvm/book3s.c
> +++ b/arch/powerpc/kvm/book3s.c
> @@ -366,7 +366,7 @@ int kvmppc_core_prepare_to_enter(struct kvm_vcpu *vcpu)
>  }
>  EXPORT_SYMBOL_GPL(kvmppc_core_prepare_to_enter);
>  
> -pfn_t kvmppc_gpa_to_pfn(struct kvm_vcpu *vcpu, gpa_t gpa, bool writing,
> +kvm_pfn_t kvmppc_gpa_to_pfn(struct kvm_vcpu *vcpu, gpa_t gpa, bool writing,
>  			bool *writable)
>  {
>  	ulong mp_pa = vcpu->arch.magic_page_pa & KVM_PAM;
> @@ -379,9 +379,9 @@ pfn_t kvmppc_gpa_to_pfn(struct kvm_vcpu *vcpu, gpa_t gpa, bool writing,
>  	gpa &= ~0xFFFULL;
>  	if (unlikely(mp_pa) && unlikely((gpa & KVM_PAM) == mp_pa)) {
>  		ulong shared_page = ((ulong)vcpu->arch.shared) & PAGE_MASK;
> -		pfn_t pfn;
> +		kvm_pfn_t pfn;
>  
> -		pfn = (pfn_t)virt_to_phys((void*)shared_page) >> PAGE_SHIFT;
> +		pfn = (kvm_pfn_t)virt_to_phys((void*)shared_page) >> PAGE_SHIFT;
>  		get_page(pfn_to_page(pfn));
>  		if (writable)
>  			*writable = true;
> diff --git a/arch/powerpc/kvm/book3s_32_mmu_host.c b/arch/powerpc/kvm/book3s_32_mmu_host.c
> index d5c9bfeb0c9c..55c4d51ea3e2 100644
> --- a/arch/powerpc/kvm/book3s_32_mmu_host.c
> +++ b/arch/powerpc/kvm/book3s_32_mmu_host.c
> @@ -142,7 +142,7 @@ extern char etext[];
>  int kvmppc_mmu_map_page(struct kvm_vcpu *vcpu, struct kvmppc_pte *orig_pte,
>  			bool iswrite)
>  {
> -	pfn_t hpaddr;
> +	kvm_pfn_t hpaddr;
>  	u64 vpn;
>  	u64 vsid;
>  	struct kvmppc_sid_map *map;
> diff --git a/arch/powerpc/kvm/book3s_64_mmu_host.c b/arch/powerpc/kvm/book3s_64_mmu_host.c
> index 79ad35abd196..913cd2198fa6 100644
> --- a/arch/powerpc/kvm/book3s_64_mmu_host.c
> +++ b/arch/powerpc/kvm/book3s_64_mmu_host.c
> @@ -83,7 +83,7 @@ int kvmppc_mmu_map_page(struct kvm_vcpu *vcpu, struct kvmppc_pte *orig_pte,
>  			bool iswrite)
>  {
>  	unsigned long vpn;
> -	pfn_t hpaddr;
> +	kvm_pfn_t hpaddr;
>  	ulong hash, hpteg;
>  	u64 vsid;
>  	int ret;
> diff --git a/arch/powerpc/kvm/e500.h b/arch/powerpc/kvm/e500.h
> index 72920bed3ac6..94f04fcb373e 100644
> --- a/arch/powerpc/kvm/e500.h
> +++ b/arch/powerpc/kvm/e500.h
> @@ -41,7 +41,7 @@ enum vcpu_ftr {
>  #define E500_TLB_MAS2_ATTR	(0x7f)
>  
>  struct tlbe_ref {
> -	pfn_t pfn;		/* valid only for TLB0, except briefly */
> +	kvm_pfn_t pfn;		/* valid only for TLB0, except briefly */
>  	unsigned int flags;	/* E500_TLB_* */
>  };
>  
> diff --git a/arch/powerpc/kvm/e500_mmu_host.c b/arch/powerpc/kvm/e500_mmu_host.c
> index 4d33e199edcc..8a5bb6dfcc2d 100644
> --- a/arch/powerpc/kvm/e500_mmu_host.c
> +++ b/arch/powerpc/kvm/e500_mmu_host.c
> @@ -163,9 +163,9 @@ void kvmppc_map_magic(struct kvm_vcpu *vcpu)
>  	struct kvm_book3e_206_tlb_entry magic;
>  	ulong shared_page = ((ulong)vcpu->arch.shared) & PAGE_MASK;
>  	unsigned int stid;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
> -	pfn = (pfn_t)virt_to_phys((void *)shared_page) >> PAGE_SHIFT;
> +	pfn = (kvm_pfn_t)virt_to_phys((void *)shared_page) >> PAGE_SHIFT;
>  	get_page(pfn_to_page(pfn));
>  
>  	preempt_disable();
> @@ -246,7 +246,7 @@ static inline int tlbe_is_writable(struct kvm_book3e_206_tlb_entry *tlbe)
>  
>  static inline void kvmppc_e500_ref_setup(struct tlbe_ref *ref,
>  					 struct kvm_book3e_206_tlb_entry *gtlbe,
> -					 pfn_t pfn, unsigned int wimg)
> +					 kvm_pfn_t pfn, unsigned int wimg)
>  {
>  	ref->pfn = pfn;
>  	ref->flags = E500_TLB_VALID;
> @@ -309,7 +309,7 @@ static void kvmppc_e500_setup_stlbe(
>  	int tsize, struct tlbe_ref *ref, u64 gvaddr,
>  	struct kvm_book3e_206_tlb_entry *stlbe)
>  {
> -	pfn_t pfn = ref->pfn;
> +	kvm_pfn_t pfn = ref->pfn;
>  	u32 pr = vcpu->arch.shared->msr & MSR_PR;
>  
>  	BUG_ON(!(ref->flags & E500_TLB_VALID));
> diff --git a/arch/powerpc/kvm/trace_pr.h b/arch/powerpc/kvm/trace_pr.h
> index 810507cb688a..d44f324184fb 100644
> --- a/arch/powerpc/kvm/trace_pr.h
> +++ b/arch/powerpc/kvm/trace_pr.h
> @@ -30,7 +30,7 @@ TRACE_EVENT(kvm_book3s_reenter,
>  #ifdef CONFIG_PPC_BOOK3S_64
>  
>  TRACE_EVENT(kvm_book3s_64_mmu_map,
> -	TP_PROTO(int rflags, ulong hpteg, ulong va, pfn_t hpaddr,
> +	TP_PROTO(int rflags, ulong hpteg, ulong va, kvm_pfn_t hpaddr,
>  		 struct kvmppc_pte *orig_pte),
>  	TP_ARGS(rflags, hpteg, va, hpaddr, orig_pte),
>  
> diff --git a/arch/x86/kvm/iommu.c b/arch/x86/kvm/iommu.c
> index 5c520ebf6343..a22a488b4622 100644
> --- a/arch/x86/kvm/iommu.c
> +++ b/arch/x86/kvm/iommu.c
> @@ -43,11 +43,11 @@ static int kvm_iommu_unmap_memslots(struct kvm *kvm);
>  static void kvm_iommu_put_pages(struct kvm *kvm,
>  				gfn_t base_gfn, unsigned long npages);
>  
> -static pfn_t kvm_pin_pages(struct kvm_memory_slot *slot, gfn_t gfn,
> +static kvm_pfn_t kvm_pin_pages(struct kvm_memory_slot *slot, gfn_t gfn,
>  			   unsigned long npages)
>  {
>  	gfn_t end_gfn;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	pfn     = gfn_to_pfn_memslot(slot, gfn);
>  	end_gfn = gfn + npages;
> @@ -62,7 +62,8 @@ static pfn_t kvm_pin_pages(struct kvm_memory_slot *slot, gfn_t gfn,
>  	return pfn;
>  }
>  
> -static void kvm_unpin_pages(struct kvm *kvm, pfn_t pfn, unsigned long npages)
> +static void kvm_unpin_pages(struct kvm *kvm, kvm_pfn_t pfn,
> +		unsigned long npages)
>  {
>  	unsigned long i;
>  
> @@ -73,7 +74,7 @@ static void kvm_unpin_pages(struct kvm *kvm, pfn_t pfn, unsigned long npages)
>  int kvm_iommu_map_pages(struct kvm *kvm, struct kvm_memory_slot *slot)
>  {
>  	gfn_t gfn, end_gfn;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	int r = 0;
>  	struct iommu_domain *domain = kvm->arch.iommu_domain;
>  	int flags;
> @@ -275,7 +276,7 @@ static void kvm_iommu_put_pages(struct kvm *kvm,
>  {
>  	struct iommu_domain *domain;
>  	gfn_t end_gfn, gfn;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	u64 phys;
>  
>  	domain  = kvm->arch.iommu_domain;
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index ff606f507913..6ab963ae0427 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -259,7 +259,7 @@ static unsigned get_mmio_spte_access(u64 spte)
>  }
>  
>  static bool set_mmio_spte(struct kvm_vcpu *vcpu, u64 *sptep, gfn_t gfn,
> -			  pfn_t pfn, unsigned access)
> +			  kvm_pfn_t pfn, unsigned access)
>  {
>  	if (unlikely(is_noslot_pfn(pfn))) {
>  		mark_mmio_spte(vcpu, sptep, gfn, access);
> @@ -325,7 +325,7 @@ static int is_last_spte(u64 pte, int level)
>  	return 0;
>  }
>  
> -static pfn_t spte_to_pfn(u64 pte)
> +static kvm_pfn_t spte_to_pfn(u64 pte)
>  {
>  	return (pte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT;
>  }
> @@ -587,7 +587,7 @@ static bool mmu_spte_update(u64 *sptep, u64 new_spte)
>   */
>  static int mmu_spte_clear_track_bits(u64 *sptep)
>  {
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	u64 old_spte = *sptep;
>  
>  	if (!spte_has_volatile_bits(old_spte))
> @@ -1369,7 +1369,7 @@ static int kvm_set_pte_rmapp(struct kvm *kvm, unsigned long *rmapp,
>  	int need_flush = 0;
>  	u64 new_spte;
>  	pte_t *ptep = (pte_t *)data;
> -	pfn_t new_pfn;
> +	kvm_pfn_t new_pfn;
>  
>  	WARN_ON(pte_huge(*ptep));
>  	new_pfn = pte_pfn(*ptep);
> @@ -2456,7 +2456,7 @@ static int mmu_need_write_protect(struct kvm_vcpu *vcpu, gfn_t gfn,
>  	return 0;
>  }
>  
> -static bool kvm_is_mmio_pfn(pfn_t pfn)
> +static bool kvm_is_mmio_pfn(kvm_pfn_t pfn)
>  {
>  	if (pfn_valid(pfn))
>  		return !is_zero_pfn(pfn) && PageReserved(pfn_to_page(pfn));
> @@ -2466,7 +2466,7 @@ static bool kvm_is_mmio_pfn(pfn_t pfn)
>  
>  static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
>  		    unsigned pte_access, int level,
> -		    gfn_t gfn, pfn_t pfn, bool speculative,
> +		    gfn_t gfn, kvm_pfn_t pfn, bool speculative,
>  		    bool can_unsync, bool host_writable)
>  {
>  	u64 spte;
> @@ -2546,7 +2546,7 @@ done:
>  
>  static void mmu_set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
>  			 unsigned pte_access, int write_fault, int *emulate,
> -			 int level, gfn_t gfn, pfn_t pfn, bool speculative,
> +			 int level, gfn_t gfn, kvm_pfn_t pfn, bool speculative,
>  			 bool host_writable)
>  {
>  	int was_rmapped = 0;
> @@ -2606,7 +2606,7 @@ static void mmu_set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
>  	kvm_release_pfn_clean(pfn);
>  }
>  
> -static pfn_t pte_prefetch_gfn_to_pfn(struct kvm_vcpu *vcpu, gfn_t gfn,
> +static kvm_pfn_t pte_prefetch_gfn_to_pfn(struct kvm_vcpu *vcpu, gfn_t gfn,
>  				     bool no_dirty_log)
>  {
>  	struct kvm_memory_slot *slot;
> @@ -2689,7 +2689,7 @@ static void direct_pte_prefetch(struct kvm_vcpu *vcpu, u64 *sptep)
>  }
>  
>  static int __direct_map(struct kvm_vcpu *vcpu, gpa_t v, int write,
> -			int map_writable, int level, gfn_t gfn, pfn_t pfn,
> +			int map_writable, int level, gfn_t gfn, kvm_pfn_t pfn,
>  			bool prefault)
>  {
>  	struct kvm_shadow_walk_iterator iterator;
> @@ -2739,7 +2739,7 @@ static void kvm_send_hwpoison_signal(unsigned long address, struct task_struct *
>  	send_sig_info(SIGBUS, &info, tsk);
>  }
>  
> -static int kvm_handle_bad_page(struct kvm_vcpu *vcpu, gfn_t gfn, pfn_t pfn)
> +static int kvm_handle_bad_page(struct kvm_vcpu *vcpu, gfn_t gfn, kvm_pfn_t pfn)
>  {
>  	/*
>  	 * Do not cache the mmio info caused by writing the readonly gfn
> @@ -2759,9 +2759,10 @@ static int kvm_handle_bad_page(struct kvm_vcpu *vcpu, gfn_t gfn, pfn_t pfn)
>  }
>  
>  static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
> -					gfn_t *gfnp, pfn_t *pfnp, int *levelp)
> +					gfn_t *gfnp, kvm_pfn_t *pfnp,
> +					int *levelp)
>  {
> -	pfn_t pfn = *pfnp;
> +	kvm_pfn_t pfn = *pfnp;
>  	gfn_t gfn = *gfnp;
>  	int level = *levelp;
>  
> @@ -2800,7 +2801,7 @@ static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
>  }
>  
>  static bool handle_abnormal_pfn(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
> -				pfn_t pfn, unsigned access, int *ret_val)
> +				kvm_pfn_t pfn, unsigned access, int *ret_val)
>  {
>  	bool ret = true;
>  
> @@ -2954,7 +2955,7 @@ exit:
>  }
>  
>  static bool try_async_pf(struct kvm_vcpu *vcpu, bool prefault, gfn_t gfn,
> -			 gva_t gva, pfn_t *pfn, bool write, bool *writable);
> +			 gva_t gva, kvm_pfn_t *pfn, bool write, bool *writable);
>  static void make_mmu_pages_available(struct kvm_vcpu *vcpu);
>  
>  static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, u32 error_code,
> @@ -2963,7 +2964,7 @@ static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, u32 error_code,
>  	int r;
>  	int level;
>  	int force_pt_level;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	unsigned long mmu_seq;
>  	bool map_writable, write = error_code & PFERR_WRITE_MASK;
>  
> @@ -3435,7 +3436,7 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
>  }
>  
>  static bool try_async_pf(struct kvm_vcpu *vcpu, bool prefault, gfn_t gfn,
> -			 gva_t gva, pfn_t *pfn, bool write, bool *writable)
> +			 gva_t gva, kvm_pfn_t *pfn, bool write, bool *writable)
>  {
>  	struct kvm_memory_slot *slot;
>  	bool async;
> @@ -3473,7 +3474,7 @@ check_hugepage_cache_consistency(struct kvm_vcpu *vcpu, gfn_t gfn, int level)
>  static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
>  			  bool prefault)
>  {
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	int r;
>  	int level;
>  	int force_pt_level;
> @@ -4627,7 +4628,7 @@ static bool kvm_mmu_zap_collapsible_spte(struct kvm *kvm,
>  	u64 *sptep;
>  	struct rmap_iterator iter;
>  	int need_tlb_flush = 0;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	struct kvm_mmu_page *sp;
>  
>  restart:
> diff --git a/arch/x86/kvm/mmu_audit.c b/arch/x86/kvm/mmu_audit.c
> index 03d518e499a6..37a4d14115c0 100644
> --- a/arch/x86/kvm/mmu_audit.c
> +++ b/arch/x86/kvm/mmu_audit.c
> @@ -97,7 +97,7 @@ static void audit_mappings(struct kvm_vcpu *vcpu, u64 *sptep, int level)
>  {
>  	struct kvm_mmu_page *sp;
>  	gfn_t gfn;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	hpa_t hpa;
>  
>  	sp = page_header(__pa(sptep));
> diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> index 736e6ab8784d..9dd02cb74724 100644
> --- a/arch/x86/kvm/paging_tmpl.h
> +++ b/arch/x86/kvm/paging_tmpl.h
> @@ -456,7 +456,7 @@ FNAME(prefetch_gpte)(struct kvm_vcpu *vcpu, struct kvm_mmu_page *sp,
>  {
>  	unsigned pte_access;
>  	gfn_t gfn;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	if (FNAME(prefetch_invalid_gpte)(vcpu, sp, spte, gpte))
>  		return false;
> @@ -551,7 +551,7 @@ static void FNAME(pte_prefetch)(struct kvm_vcpu *vcpu, struct guest_walker *gw,
>  static int FNAME(fetch)(struct kvm_vcpu *vcpu, gva_t addr,
>  			 struct guest_walker *gw,
>  			 int write_fault, int hlevel,
> -			 pfn_t pfn, bool map_writable, bool prefault)
> +			 kvm_pfn_t pfn, bool map_writable, bool prefault)
>  {
>  	struct kvm_mmu_page *sp = NULL;
>  	struct kvm_shadow_walk_iterator it;
> @@ -696,7 +696,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr, u32 error_code,
>  	int user_fault = error_code & PFERR_USER_MASK;
>  	struct guest_walker walker;
>  	int r;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  	int level = PT_PAGE_TABLE_LEVEL;
>  	int force_pt_level;
>  	unsigned long mmu_seq;
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 06ef4908ba61..d401ed6874bd 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -4046,7 +4046,7 @@ out:
>  static int init_rmode_identity_map(struct kvm *kvm)
>  {
>  	int i, idx, r = 0;
> -	pfn_t identity_map_pfn;
> +	kvm_pfn_t identity_map_pfn;
>  	u32 tmp;
>  
>  	if (!enable_ept)
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 92511d4b7236..8fc5ca584edf 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -4935,7 +4935,7 @@ static bool reexecute_instruction(struct kvm_vcpu *vcpu, gva_t cr2,
>  				  int emulation_type)
>  {
>  	gpa_t gpa = cr2;
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	if (emulation_type & EMULTYPE_NO_REEXECUTE)
>  		return false;
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 1bef9e21e725..2420b43f3acc 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -65,7 +65,7 @@
>   * error pfns indicate that the gfn is in slot but faild to
>   * translate it to pfn on host.
>   */
> -static inline bool is_error_pfn(pfn_t pfn)
> +static inline bool is_error_pfn(kvm_pfn_t pfn)
>  {
>  	return !!(pfn & KVM_PFN_ERR_MASK);
>  }
> @@ -75,13 +75,13 @@ static inline bool is_error_pfn(pfn_t pfn)
>   * translated to pfn - it is not in slot or failed to
>   * translate it to pfn.
>   */
> -static inline bool is_error_noslot_pfn(pfn_t pfn)
> +static inline bool is_error_noslot_pfn(kvm_pfn_t pfn)
>  {
>  	return !!(pfn & KVM_PFN_ERR_NOSLOT_MASK);
>  }
>  
>  /* noslot pfn indicates that the gfn is not in slot. */
> -static inline bool is_noslot_pfn(pfn_t pfn)
> +static inline bool is_noslot_pfn(kvm_pfn_t pfn)
>  {
>  	return pfn == KVM_PFN_NOSLOT;
>  }
> @@ -569,19 +569,20 @@ void kvm_release_page_clean(struct page *page);
>  void kvm_release_page_dirty(struct page *page);
>  void kvm_set_page_accessed(struct page *page);
>  
> -pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn);
> -pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn);
> -pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
> +kvm_pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn);
> +kvm_pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn);
> +kvm_pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
>  		      bool *writable);
> -pfn_t gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn);
> -pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn);
> -pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn, bool atomic,
> -			   bool *async, bool write_fault, bool *writable);
> +kvm_pfn_t gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn);
> +kvm_pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn);
> +kvm_pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn,
> +			       bool atomic, bool *async, bool write_fault,
> +			       bool *writable);
>  
> -void kvm_release_pfn_clean(pfn_t pfn);
> -void kvm_set_pfn_dirty(pfn_t pfn);
> -void kvm_set_pfn_accessed(pfn_t pfn);
> -void kvm_get_pfn(pfn_t pfn);
> +void kvm_release_pfn_clean(kvm_pfn_t pfn);
> +void kvm_set_pfn_dirty(kvm_pfn_t pfn);
> +void kvm_set_pfn_accessed(kvm_pfn_t pfn);
> +void kvm_get_pfn(kvm_pfn_t pfn);
>  
>  int kvm_read_guest_page(struct kvm *kvm, gfn_t gfn, void *data, int offset,
>  			int len);
> @@ -607,8 +608,8 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn);
>  
>  struct kvm_memslots *kvm_vcpu_memslots(struct kvm_vcpu *vcpu);
>  struct kvm_memory_slot *kvm_vcpu_gfn_to_memslot(struct kvm_vcpu *vcpu, gfn_t gfn);
> -pfn_t kvm_vcpu_gfn_to_pfn_atomic(struct kvm_vcpu *vcpu, gfn_t gfn);
> -pfn_t kvm_vcpu_gfn_to_pfn(struct kvm_vcpu *vcpu, gfn_t gfn);
> +kvm_pfn_t kvm_vcpu_gfn_to_pfn_atomic(struct kvm_vcpu *vcpu, gfn_t gfn);
> +kvm_pfn_t kvm_vcpu_gfn_to_pfn(struct kvm_vcpu *vcpu, gfn_t gfn);
>  struct page *kvm_vcpu_gfn_to_page(struct kvm_vcpu *vcpu, gfn_t gfn);
>  unsigned long kvm_vcpu_gfn_to_hva(struct kvm_vcpu *vcpu, gfn_t gfn);
>  unsigned long kvm_vcpu_gfn_to_hva_prot(struct kvm_vcpu *vcpu, gfn_t gfn, bool *writable);
> @@ -789,7 +790,7 @@ void kvm_arch_sync_events(struct kvm *kvm);
>  int kvm_cpu_has_pending_timer(struct kvm_vcpu *vcpu);
>  void kvm_vcpu_kick(struct kvm_vcpu *vcpu);
>  
> -bool kvm_is_reserved_pfn(pfn_t pfn);
> +bool kvm_is_reserved_pfn(kvm_pfn_t pfn);
>  
>  struct kvm_irq_ack_notifier {
>  	struct hlist_node link;
> @@ -940,7 +941,7 @@ static inline gfn_t gpa_to_gfn(gpa_t gpa)
>  	return (gfn_t)(gpa >> PAGE_SHIFT);
>  }
>  
> -static inline hpa_t pfn_to_hpa(pfn_t pfn)
> +static inline hpa_t pfn_to_hpa(kvm_pfn_t pfn)
>  {
>  	return (hpa_t)pfn << PAGE_SHIFT;
>  }
> diff --git a/include/linux/kvm_types.h b/include/linux/kvm_types.h
> index 1b47a185c2f0..8bf259dae9f6 100644
> --- a/include/linux/kvm_types.h
> +++ b/include/linux/kvm_types.h
> @@ -53,7 +53,7 @@ typedef unsigned long  hva_t;
>  typedef u64            hpa_t;
>  typedef u64            hfn_t;
>  
> -typedef hfn_t pfn_t;
> +typedef hfn_t kvm_pfn_t;
>  
>  struct gfn_to_hva_cache {
>  	u64 generation;
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 8db1d9361993..02cd2eddd3ff 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -111,7 +111,7 @@ static void hardware_disable_all(void);
>  
>  static void kvm_io_bus_destroy(struct kvm_io_bus *bus);
>  
> -static void kvm_release_pfn_dirty(pfn_t pfn);
> +static void kvm_release_pfn_dirty(kvm_pfn_t pfn);
>  static void mark_page_dirty_in_slot(struct kvm_memory_slot *memslot, gfn_t gfn);
>  
>  __visible bool kvm_rebooting;
> @@ -119,7 +119,7 @@ EXPORT_SYMBOL_GPL(kvm_rebooting);
>  
>  static bool largepages_enabled = true;
>  
> -bool kvm_is_reserved_pfn(pfn_t pfn)
> +bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>  {
>  	if (pfn_valid(pfn))
>  		return PageReserved(pfn_to_page(pfn));
> @@ -1296,7 +1296,7 @@ static inline int check_user_page_hwpoison(unsigned long addr)
>   * true indicates success, otherwise false is returned.
>   */
>  static bool hva_to_pfn_fast(unsigned long addr, bool atomic, bool *async,
> -			    bool write_fault, bool *writable, pfn_t *pfn)
> +			    bool write_fault, bool *writable, kvm_pfn_t *pfn)
>  {
>  	struct page *page[1];
>  	int npages;
> @@ -1329,7 +1329,7 @@ static bool hva_to_pfn_fast(unsigned long addr, bool atomic, bool *async,
>   * 1 indicates success, -errno is returned if error is detected.
>   */
>  static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
> -			   bool *writable, pfn_t *pfn)
> +			   bool *writable, kvm_pfn_t *pfn)
>  {
>  	struct page *page[1];
>  	int npages = 0;
> @@ -1393,11 +1393,11 @@ static bool vma_is_valid(struct vm_area_struct *vma, bool write_fault)
>   * 2): @write_fault = false && @writable, @writable will tell the caller
>   *     whether the mapping is writable.
>   */
> -static pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
> +static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
>  			bool write_fault, bool *writable)
>  {
>  	struct vm_area_struct *vma;
> -	pfn_t pfn = 0;
> +	kvm_pfn_t pfn = 0;
>  	int npages;
>  
>  	/* we can do it either atomically or asynchronously, not both */
> @@ -1438,8 +1438,9 @@ exit:
>  	return pfn;
>  }
>  
> -pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn, bool atomic,
> -			   bool *async, bool write_fault, bool *writable)
> +kvm_pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn,
> +			       bool atomic, bool *async, bool write_fault,
> +			       bool *writable)
>  {
>  	unsigned long addr = __gfn_to_hva_many(slot, gfn, NULL, write_fault);
>  
> @@ -1460,7 +1461,7 @@ pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn, bool atomic,
>  }
>  EXPORT_SYMBOL_GPL(__gfn_to_pfn_memslot);
>  
> -pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
> +kvm_pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
>  		      bool *writable)
>  {
>  	return __gfn_to_pfn_memslot(gfn_to_memslot(kvm, gfn), gfn, false, NULL,
> @@ -1468,37 +1469,37 @@ pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
>  }
>  EXPORT_SYMBOL_GPL(gfn_to_pfn_prot);
>  
> -pfn_t gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn)
> +kvm_pfn_t gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn)
>  {
>  	return __gfn_to_pfn_memslot(slot, gfn, false, NULL, true, NULL);
>  }
>  EXPORT_SYMBOL_GPL(gfn_to_pfn_memslot);
>  
> -pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn)
> +kvm_pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn)
>  {
>  	return __gfn_to_pfn_memslot(slot, gfn, true, NULL, true, NULL);
>  }
>  EXPORT_SYMBOL_GPL(gfn_to_pfn_memslot_atomic);
>  
> -pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn)
> +kvm_pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn)
>  {
>  	return gfn_to_pfn_memslot_atomic(gfn_to_memslot(kvm, gfn), gfn);
>  }
>  EXPORT_SYMBOL_GPL(gfn_to_pfn_atomic);
>  
> -pfn_t kvm_vcpu_gfn_to_pfn_atomic(struct kvm_vcpu *vcpu, gfn_t gfn)
> +kvm_pfn_t kvm_vcpu_gfn_to_pfn_atomic(struct kvm_vcpu *vcpu, gfn_t gfn)
>  {
>  	return gfn_to_pfn_memslot_atomic(kvm_vcpu_gfn_to_memslot(vcpu, gfn), gfn);
>  }
>  EXPORT_SYMBOL_GPL(kvm_vcpu_gfn_to_pfn_atomic);
>  
> -pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn)
> +kvm_pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn)
>  {
>  	return gfn_to_pfn_memslot(gfn_to_memslot(kvm, gfn), gfn);
>  }
>  EXPORT_SYMBOL_GPL(gfn_to_pfn);
>  
> -pfn_t kvm_vcpu_gfn_to_pfn(struct kvm_vcpu *vcpu, gfn_t gfn)
> +kvm_pfn_t kvm_vcpu_gfn_to_pfn(struct kvm_vcpu *vcpu, gfn_t gfn)
>  {
>  	return gfn_to_pfn_memslot(kvm_vcpu_gfn_to_memslot(vcpu, gfn), gfn);
>  }
> @@ -1521,7 +1522,7 @@ int gfn_to_page_many_atomic(struct kvm_memory_slot *slot, gfn_t gfn,
>  }
>  EXPORT_SYMBOL_GPL(gfn_to_page_many_atomic);
>  
> -static struct page *kvm_pfn_to_page(pfn_t pfn)
> +static struct page *kvm_pfn_to_page(kvm_pfn_t pfn)
>  {
>  	if (is_error_noslot_pfn(pfn))
>  		return KVM_ERR_PTR_BAD_PAGE;
> @@ -1536,7 +1537,7 @@ static struct page *kvm_pfn_to_page(pfn_t pfn)
>  
>  struct page *gfn_to_page(struct kvm *kvm, gfn_t gfn)
>  {
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	pfn = gfn_to_pfn(kvm, gfn);
>  
> @@ -1546,7 +1547,7 @@ EXPORT_SYMBOL_GPL(gfn_to_page);
>  
>  struct page *kvm_vcpu_gfn_to_page(struct kvm_vcpu *vcpu, gfn_t gfn)
>  {
> -	pfn_t pfn;
> +	kvm_pfn_t pfn;
>  
>  	pfn = kvm_vcpu_gfn_to_pfn(vcpu, gfn);
>  
> @@ -1562,7 +1563,7 @@ void kvm_release_page_clean(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(kvm_release_page_clean);
>  
> -void kvm_release_pfn_clean(pfn_t pfn)
> +void kvm_release_pfn_clean(kvm_pfn_t pfn)
>  {
>  	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn))
>  		put_page(pfn_to_page(pfn));
> @@ -1577,13 +1578,13 @@ void kvm_release_page_dirty(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(kvm_release_page_dirty);
>  
> -static void kvm_release_pfn_dirty(pfn_t pfn)
> +static void kvm_release_pfn_dirty(kvm_pfn_t pfn)
>  {
>  	kvm_set_pfn_dirty(pfn);
>  	kvm_release_pfn_clean(pfn);
>  }
>  
> -void kvm_set_pfn_dirty(pfn_t pfn)
> +void kvm_set_pfn_dirty(kvm_pfn_t pfn)
>  {
>  	if (!kvm_is_reserved_pfn(pfn)) {
>  		struct page *page = pfn_to_page(pfn);
> @@ -1594,14 +1595,14 @@ void kvm_set_pfn_dirty(pfn_t pfn)
>  }
>  EXPORT_SYMBOL_GPL(kvm_set_pfn_dirty);
>  
> -void kvm_set_pfn_accessed(pfn_t pfn)
> +void kvm_set_pfn_accessed(kvm_pfn_t pfn)
>  {
>  	if (!kvm_is_reserved_pfn(pfn))
>  		mark_page_accessed(pfn_to_page(pfn));
>  }
>  EXPORT_SYMBOL_GPL(kvm_set_pfn_accessed);
>  
> -void kvm_get_pfn(pfn_t pfn)
> +void kvm_get_pfn(kvm_pfn_t pfn)
>  {
>  	if (!kvm_is_reserved_pfn(pfn))
>  		get_page(pfn_to_page(pfn));
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
