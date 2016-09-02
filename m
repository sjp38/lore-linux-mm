From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 01/20] x86: Documentation for AMD Secure Memory
	Encryption (SME)
Date: Fri, 2 Sep 2016 10:50:45 +0200
Message-ID: <20160902085045.GG17338@nazgul.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223539.29880.96739.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223539.29880.96739.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:35:39PM -0500, Tom Lendacky wrote:
> This patch adds a Documenation entry to decribe the AMD Secure Memory
> Encryption (SME) feature.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  Documentation/x86/amd-memory-encryption.txt |   35 +++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
> 
> diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
> new file mode 100644
> index 0000000..f19c555
> --- /dev/null
> +++ b/Documentation/x86/amd-memory-encryption.txt
> @@ -0,0 +1,35 @@
> +Secure Memory Encryption (SME) is a feature found on AMD processors.
> +
> +SME provides the ability to mark individual pages of memory as encrypted using
> +the standard x86 page tables.  A page that is marked encrpyted will be

s/encrpyted/encrypted/

> +automatically decrypted when read from DRAM and encrypted when written to
> +DRAM.  SME can therefore be used to protect the contents of DRAM from physical
> +attacks on the system.
> +
> +Support for SME can be determined through the CPUID instruction. The CPUID
> +function 0x8000001f reports information related to SME:
> +
> +	0x8000001f[eax]:
> +		Bit[0] indicates support for SME
> +	0x8000001f[ebx]:
> +		Bit[5:0]  pagetable bit number used to enable memory encryption
> +		Bit[11:6] reduction in physical address space, in bits, when
> +			  memory encryption is enabled (this only affects system
> +			  physical addresses, not guest physical addresses)
> +
> +If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to
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
> +SME support is configurable in the kernel through the AMD_MEM_ENCRYPT config
> +option.

" ... is configurable through CONFIG_AMD_MEM_ENCRYPT."

> Additionally, the mem_encrypt=on command line parameter is required
> +to activate memory encryption.

I think you want to rewrite the logic here to say that people should use
the BIOS option and if none is present for whatever reason, resort to
the alternative "mem_encrypt=on" kernel command line option, no?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
