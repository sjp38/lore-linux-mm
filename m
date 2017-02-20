From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v4 06/28] x86: Add support to enable SME during early
	boot processing
Date: Mon, 20 Feb 2017 13:51:31 +0100
Message-ID: <20170220125131.cenb2subqjcqf2xr@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	<20170216154319.19244.7863.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216154319.19244.7863.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Thu, Feb 16, 2017 at 09:43:19AM -0600, Tom Lendacky wrote:
> This patch adds support to the early boot code to use Secure Memory
> Encryption (SME).  Support is added to update the early pagetables with
> the memory encryption mask and to encrypt the kernel in place.
> 
> The routines to set the encryption mask and perform the encryption are
> stub routines for now with full function to be added in a later patch.

s/full function/functionality/

> A new file, arch/x86/kernel/mem_encrypt_init.c, is introduced to avoid
> adding #ifdefs within arch/x86/kernel/head_64.S and allow
> arch/x86/mm/mem_encrypt.c to be removed from the build if SME is not
> configured. The mem_encrypt_init.c file will contain the necessary #ifdefs
> to allow head_64.S to successfully build and call the SME routines.

That paragraph is superfluous.

> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/kernel/Makefile           |    2 +
>  arch/x86/kernel/head_64.S          |   46 ++++++++++++++++++++++++++++++++-
>  arch/x86/kernel/mem_encrypt_init.c |   50 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 96 insertions(+), 2 deletions(-)
>  create mode 100644 arch/x86/kernel/mem_encrypt_init.c
> 
> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> index bdcdb3b..33af80a 100644
> --- a/arch/x86/kernel/Makefile
> +++ b/arch/x86/kernel/Makefile
> @@ -140,4 +140,6 @@ ifeq ($(CONFIG_X86_64),y)
>  
>  	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
>  	obj-y				+= vsmp_64.o
> +
> +	obj-y				+= mem_encrypt_init.o
>  endif
> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
> index b467b14..4f8201b 100644
> --- a/arch/x86/kernel/head_64.S
> +++ b/arch/x86/kernel/head_64.S
> @@ -91,6 +91,23 @@ startup_64:
>  	jnz	bad_address
>  
>  	/*
> +	 * Enable Secure Memory Encryption (SME), if supported and enabled.
> +	 * The real_mode_data address is in %rsi and that register can be
> +	 * clobbered by the called function so be sure to save it.
> +	 * Save the returned mask in %r12 for later use.
> +	 */
> +	push	%rsi
> +	call	sme_enable
> +	pop	%rsi
> +	movq	%rax, %r12
> +
> +	/*
> +	 * Add the memory encryption mask to %rbp to include it in the page
> +	 * table fixups.
> +	 */
> +	addq	%r12, %rbp
> +
> +	/*
>  	 * Fixup the physical addresses in the page table
>  	 */
>  	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
> @@ -113,6 +130,7 @@ startup_64:
>  	shrq	$PGDIR_SHIFT, %rax
>  
>  	leaq	(PAGE_SIZE + _KERNPG_TABLE)(%rbx), %rdx
> +	addq	%r12, %rdx
>  	movq	%rdx, 0(%rbx,%rax,8)
>  	movq	%rdx, 8(%rbx,%rax,8)
>  
> @@ -129,6 +147,7 @@ startup_64:
>  	movq	%rdi, %rax
>  	shrq	$PMD_SHIFT, %rdi
>  	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
> +	addq	%r12, %rax
>  	leaq	(_end - 1)(%rip), %rcx
>  	shrq	$PMD_SHIFT, %rcx
>  	subq	%rdi, %rcx
> @@ -162,11 +181,25 @@ startup_64:
>  	cmp	%r8, %rdi
>  	jne	1b
>  
> -	/* Fixup phys_base */
> +	/*
> +	 * Fixup phys_base - remove the memory encryption mask from %rbp
> +	 * to obtain the true physical address.
> +	 */
> +	subq	%r12, %rbp
>  	addq	%rbp, phys_base(%rip)
>  
> +	/*
> +	 * Encrypt the kernel if SME is active.
> +	 * The real_mode_data address is in %rsi and that register can be
> +	 * clobbered by the called function so be sure to save it.
> +	 */
> +	push	%rsi
> +	call	sme_encrypt_kernel
> +	pop	%rsi
> +
>  .Lskip_fixup:

So if we land on this label because we can skip the fixup due to %rbp
being 0, we will skip sme_encrypt_kernel() too.

I think you need to move the .Lskip_fixup label above the
sme_encrypt_kernel call.

>  	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
> +	addq	%r12, %rax
>  	jmp 1f
>  ENTRY(secondary_startup_64)
>  	/*
> @@ -186,7 +219,16 @@ ENTRY(secondary_startup_64)
>  	/* Sanitize CPU configuration */
>  	call verify_cpu
>  
> -	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
> +	/*
> +	 * Get the SME encryption mask.
> +	 * The real_mode_data address is in %rsi and that register can be
> +	 * clobbered by the called function so be sure to save it.

You can say here that sme_get_me_mask puts the mask in %rax, that's why
we do ADD below and not MOV. I know, it is very explicit but this is
boot asm and I'd prefer for it to be absolutely clear.

> +	 */
> +	push	%rsi
> +	call	sme_get_me_mask
> +	pop	%rsi
> +
> +	addq	$(init_level4_pgt - __START_KERNEL_map), %rax
>  1:

...

> +#else	/* !CONFIG_AMD_MEM_ENCRYPT */
> +
> +void __init sme_encrypt_kernel(void)
> +{
> +}
> +
> +unsigned long __init sme_get_me_mask(void)
> +{
> +	return 0;
> +}
> +
> +unsigned long __init sme_enable(void)
> +{
> +	return 0;
> +}

Do that:

void __init sme_encrypt_kernel(void)            { }
unsigned long __init sme_get_me_mask(void)      { return 0; }
unsigned long __init sme_enable(void)           { return 0; }

to save some lines.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
