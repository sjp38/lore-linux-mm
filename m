From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v4 07/28] x86: Provide general kernel support for
	memory encryption
Date: Mon, 20 Feb 2017 16:21:52 +0100
Message-ID: <20170220152152.apdfjjuvu2u56tik@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	<20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216154332.19244.55451.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brijesh Singh <brijesh.singh-5C7GfCeVMHo@public.gmane.org>, Toshimitsu Kani <toshi.kani-ZPxbGqLxI0U@public.gmane.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 16, 2017 at 09:43:32AM -0600, Tom Lendacky wrote:
> Adding general kernel support for memory encryption includes:
> - Modify and create some page table macros to include the Secure Memory
>   Encryption (SME) memory encryption mask

Let's not write it like some technical document: "Secure Memory
Encryption (SME) mask" is perfectly fine.

> - Modify and create some macros for calculating physical and virtual
>   memory addresses
> - Provide an SME initialization routine to update the protection map with
>   the memory encryption mask so that it is used by default
> - #undef CONFIG_AMD_MEM_ENCRYPT in the compressed boot path

These bulletpoints talk about the "what" this patch does but they should
talk about the "why".

For example, it doesn't say why we're using _KERNPG_TABLE_NOENC when
building the initial pagetable and that would be an interesting piece of
information.

> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/boot/compressed/pagetable.c |    7 +++++
>  arch/x86/include/asm/fixmap.h        |    7 +++++
>  arch/x86/include/asm/mem_encrypt.h   |   14 +++++++++++
>  arch/x86/include/asm/page.h          |    4 ++-
>  arch/x86/include/asm/pgtable.h       |   26 ++++++++++++++------
>  arch/x86/include/asm/pgtable_types.h |   45 ++++++++++++++++++++++------------
>  arch/x86/include/asm/processor.h     |    3 ++
>  arch/x86/kernel/espfix_64.c          |    2 +-
>  arch/x86/kernel/head64.c             |   12 ++++++++-
>  arch/x86/kernel/head_64.S            |   18 +++++++-------
>  arch/x86/mm/kasan_init_64.c          |    4 ++-
>  arch/x86/mm/mem_encrypt.c            |   20 +++++++++++++++
>  arch/x86/mm/pageattr.c               |    3 ++
>  include/asm-generic/pgtable.h        |    8 ++++++
>  14 files changed, 133 insertions(+), 40 deletions(-)
> 
> diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
> index 56589d0..411c443 100644
> --- a/arch/x86/boot/compressed/pagetable.c
> +++ b/arch/x86/boot/compressed/pagetable.c
> @@ -15,6 +15,13 @@
>  #define __pa(x)  ((unsigned long)(x))
>  #define __va(x)  ((void *)((unsigned long)(x)))
>  
> +/*
> + * The pgtable.h and mm/ident_map.c includes make use of the SME related
> + * information which is not used in the compressed image support. Un-define
> + * the SME support to avoid any compile and link errors.
> + */
> +#undef CONFIG_AMD_MEM_ENCRYPT
> +
>  #include "misc.h"
>  
>  /* These actually do the work of building the kernel identity maps. */
> diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
> index 8554f96..83e91f0 100644
> --- a/arch/x86/include/asm/fixmap.h
> +++ b/arch/x86/include/asm/fixmap.h
> @@ -153,6 +153,13 @@ static inline void __set_fixmap(enum fixed_addresses idx,
>  }
>  #endif
>  
> +/*
> + * Fixmap settings used with memory encryption
> + *   - FIXMAP_PAGE_NOCACHE is used for MMIO so make sure the memory
> + *     encryption mask is not part of the page attributes

Make that a regular sentence.

> + */
> +#define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_IO_NOCACHE
> +
>  #include <asm-generic/fixmap.h>
>  
>  #define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index ccc53b0..547989d 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -15,6 +15,8 @@
>  
>  #ifndef __ASSEMBLY__
>  
> +#include <linux/init.h>
> +
>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>  
>  extern unsigned long sme_me_mask;
> @@ -24,6 +26,11 @@ static inline bool sme_active(void)
>  	return (sme_me_mask) ? true : false;
>  }
>  
> +void __init sme_early_init(void);
> +
> +#define __sme_pa(x)		(__pa((x)) | sme_me_mask)
> +#define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)

Right, I know we did talk about those but in looking more into the
future, you'd have to go educate people to use the __sme_pa* variants.
Otherwise, we'd have to go and fix up code on AMD SME machines because
someone used __pa_* variants where someone should have been using the
__sma_pa_* variants.

IOW, should we simply put sme_me_mask in the actual __pa* macro
definitions?

Or are we saying that the __sme_pa* versions you have above are
the special ones and we need them only in a handful of places like
load_cr3(), for example...? And the __pa_* ones should return the
physical address without the SME mask because callers don't need it?

> +
>  #else	/* !CONFIG_AMD_MEM_ENCRYPT */
>  
>  #ifndef sme_me_mask
> @@ -35,6 +42,13 @@ static inline bool sme_active(void)
>  }
>  #endif
>  
> +static inline void __init sme_early_init(void)
> +{
> +}
> +
> +#define __sme_pa		__pa
> +#define __sme_pa_nodebug	__pa_nodebug
> +
>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>  
>  #endif	/* __ASSEMBLY__ */
> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> index cf8f619..b1f7bf6 100644
> --- a/arch/x86/include/asm/page.h
> +++ b/arch/x86/include/asm/page.h
> @@ -15,6 +15,8 @@
>  
>  #ifndef __ASSEMBLY__
>  
> +#include <asm/mem_encrypt.h>
> +
>  struct page;
>  
>  #include <linux/range.h>
> @@ -55,7 +57,7 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
>  	__phys_addr_symbol(__phys_reloc_hide((unsigned long)(x)))
>  
>  #ifndef __va
> -#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
> +#define __va(x)			((void *)(((unsigned long)(x) & ~sme_me_mask) + PAGE_OFFSET))

You have a bunch of places where you remove the enc mask:

	address & ~sme_me_mask

so you could do:

#define __sme_unmask(x)		((unsigned long)(x) & ~sme_me_mask)

and use it everywhere. "unmask" is what I could think of, there should
be a better, short name for it...

>  #endif
>  
>  #define __boot_va(x)		__va(x)
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 2d81161..b41caab 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -3,6 +3,7 @@

...

> @@ -563,8 +575,7 @@ static inline unsigned long pmd_page_vaddr(pmd_t pmd)
>   * Currently stuck as a macro due to indirect forward reference to
>   * linux/mmzone.h's __section_mem_map_addr() definition:
>   */
> -#define pmd_page(pmd)		\
> -	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
> +#define pmd_page(pmd)	pfn_to_page(pmd_pfn(pmd))
>  
>  /*
>   * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
> @@ -632,8 +643,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
>   * Currently stuck as a macro due to indirect forward reference to
>   * linux/mmzone.h's __section_mem_map_addr() definition:
>   */
> -#define pud_page(pud)		\
> -	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
> +#define pud_page(pud)	pfn_to_page(pud_pfn(pud))
>  
>  /* Find an entry in the second-level page table.. */
>  static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
> @@ -673,7 +683,7 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
>   * Currently stuck as a macro due to indirect forward reference to
>   * linux/mmzone.h's __section_mem_map_addr() definition:
>   */
> -#define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
> +#define pgd_page(pgd)	pfn_to_page(pgd_pfn(pgd))
>  
>  /* to find an entry in a page-table-directory. */
>  static inline unsigned long pud_index(unsigned long address)

This conversion to *_pfn() is an unrelated cleanup. Pls carve it out and
put it in the front of the patchset as a separate patch.

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index b99d469..d71df97 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -11,6 +11,10 @@
>   */
>  
>  #include <linux/linkage.h>
> +#include <linux/init.h>
> +#include <linux/mm.h>
> +
> +extern pmdval_t early_pmd_flags;

WARNING: externs should be avoided in .c files
#476: FILE: arch/x86/mm/mem_encrypt.c:17:
+extern pmdval_t early_pmd_flags;

>  /*
>   * Since SME related variables are set early in the boot process they must
> @@ -19,3 +23,19 @@
>   */
>  unsigned long sme_me_mask __section(.data) = 0;
>  EXPORT_SYMBOL_GPL(sme_me_mask);
> +
> +void __init sme_early_init(void)
> +{
> +	unsigned int i;
> +
> +	if (!sme_me_mask)
> +		return;
> +
> +	early_pmd_flags |= sme_me_mask;
> +
> +	__supported_pte_mask |= sme_me_mask;
> +
> +	/* Update the protection map with memory encryption mask */
> +	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
> +		protection_map[i] = pgprot_encrypted(protection_map[i]);
> +}

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
