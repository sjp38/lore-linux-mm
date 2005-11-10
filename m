Subject: Re: [PATCH 4/4] Hugetlb: Copy on Write support
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <1131579596.28383.25.camel@localhost.localdomain>
References: <1131578925.28383.9.camel@localhost.localdomain>
	 <1131579596.28383.25.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 09 Nov 2005 17:52:44 -0800
Message-Id: <1131587564.16514.53.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, hugh@veritas.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-09 at 17:39 -0600, Adam Litke wrote:

>  
> +#define huge_ptep_set_wrprotect(mm, addr, ptep) \
> +	ptep_set_wrprotect(mm, addr, ptep)
> +static inline void set_huge_ptep_writable(struct vm_area_struct *vma,
> +		unsigned long address, pte_t *ptep)
> +{
> +	pte_t entry;
> +
> +	entry = pte_mkwrite(pte_mkdirty(*ptep));
> +	ptep_set_access_flags(vma, address, ptep, entry, 1);
> +	update_mmu_cache(vma, address, entry);
> +}

lazy_mmu_prot_update will need to called here to make caches coherent
for some archs.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
