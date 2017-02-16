From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v4 01/28] x86: Documentation for AMD Secure Memory
	Encryption (SME)
Date: Thu, 16 Feb 2017 18:56:25 +0100
Message-ID: <20170216175625.imxsvz7fzvlpveze@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	<20170216154211.19244.76656.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216154211.19244.76656.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

Ok, this time detailed review :-)

On Thu, Feb 16, 2017 at 09:42:11AM -0600, Tom Lendacky wrote:
> This patch adds a Documenation entry to decribe the AMD Secure Memory
> Encryption (SME) feature.

Please introduce a spellchecker into your patch creation workflow. I see
two typos in one line.

Also, never start patch commit messages with "This patch" - we know it
is this patch. Always write a doer-sentences explaining the why, not the
what. Something like:

"Add a SME and mem_encrypt= kernel parameter documentation."

for example.

> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  Documentation/admin-guide/kernel-parameters.txt |   11 ++++
>  Documentation/x86/amd-memory-encryption.txt     |   57 +++++++++++++++++++++++
>  2 files changed, 68 insertions(+)
>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index 110745e..91c40fa 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2145,6 +2145,17 @@
>  			memory contents and reserves bad memory
>  			regions that are detected.
>  
> +	mem_encrypt=	[X86-64] AMD Secure Memory Encryption (SME) control
> +			Valid arguments: on, off
> +			Default (depends on kernel configuration option):
> +			  on  (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y)
> +			  off (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=n)
> +			mem_encrypt=on:		Activate SME
> +			mem_encrypt=off:	Do not activate SME
> +
> +			Refer to the SME documentation for details on when

"Refer to Documentation/x86/amd-memory-encryption.txt .."

> +			memory encryption can be activated.
> +
>  	mem_sleep_default=	[SUSPEND] Default system suspend mode:
>  			s2idle  - Suspend-To-Idle
>  			shallow - Power-On Suspend or equivalent (if supported)
> diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
> new file mode 100644
> index 0000000..0938e89
> --- /dev/null
> +++ b/Documentation/x86/amd-memory-encryption.txt
> @@ -0,0 +1,57 @@
> +Secure Memory Encryption (SME) is a feature found on AMD processors.
> +
> +SME provides the ability to mark individual pages of memory as encrypted using
> +the standard x86 page tables.  A page that is marked encrypted will be
> +automatically decrypted when read from DRAM and encrypted when written to
> +DRAM.  SME can therefore be used to protect the contents of DRAM from physical
> +attacks on the system.
> +
> +A page is encrypted when a page table entry has the encryption bit set (see
> +below how to determine the position of the bit).  The encryption bit can be

"... how to determine its position)."

> +specified in the cr3 register, allowing the PGD table to be encrypted. Each
> +successive level of page tables can also be encrypted.
> +
> +Support for SME can be determined through the CPUID instruction. The CPUID
> +function 0x8000001f reports information related to SME:
> +
> +	0x8000001f[eax]:
> +		Bit[0] indicates support for SME
> +	0x8000001f[ebx]:
> +		Bit[5:0]  pagetable bit number used to activate memory
> +			  encryption

s/Bit/Bits/

> +		Bit[11:6] reduction in physical address space, in bits, when

Ditto.

> +			  memory encryption is enabled (this only affects system
> +			  physical addresses, not guest physical addresses)
> +
> +If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to

Let's use the kernel's define name MSR_K8_SYSCFG to avoid ambiguity.

> +determine if SME is enabled and/or to enable memory encryption:
> +
> +	0xc0010010:
> +		Bit[23]   0 = memory encryption features are disabled
> +			  1 = memory encryption features are enabled
> +
> +Linux relies on BIOS to set this bit if BIOS has determined that the reduction
> +in the physical address space as a result of enabling memory encryption (see
> +CPUID information above) will not conflict with the address space resource
> +requirements for the system.  If this bit is not set upon Linux startup then
> +Linux itself will not set it and memory encryption will not be possible.
> +
> +The state of SME in the Linux kernel can be documented as follows:
> +	- Supported:
> +	  The CPU supports SME (determined through CPUID instruction).
> +
> +	- Enabled:
> +	  Supported and bit 23 of the SYS_CFG MSR is set.

Ditto.

> +
> +	- Active:
> +	  Supported, Enabled and the Linux kernel is actively applying
> +	  the encryption bit to page table entries (the SME mask in the
> +	  kernel is non-zero).
> +
> +SME can also be enabled and activated in the BIOS. If SME is enabled and
> +activated in the BIOS, then all memory accesses will be encrypted and it will
> +not be necessary to activate the Linux memory encryption support.  If the BIOS
> +merely enables SME (sets bit 23 of the SYS_CFG MSR), then Linux can activate
> +memory encryption.

"... This is done by supplying mem_encrypt=on on the kernel command line.
Alternatively, if the kernel should enable SME by default, set
CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y."

> However, if BIOS does not enable SME, then Linux will not
> +attempt to activate memory encryption, even if configured to do so by default

will not attempt or will not be able to?

> +or the mem_encrypt=on command line parameter is specified.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
