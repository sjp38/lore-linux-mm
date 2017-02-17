From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 05/28] x86: Add Secure Memory Encryption (SME)
 support
Date: Fri, 17 Feb 2017 13:00:18 +0100
Message-ID: <20170217120018.y64pf4sv2plasbsv@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154307.19244.72895.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170216154307.19244.72895.stgit@tlendack-t1.amdoffice.net>
Sender: linux-doc-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 16, 2017 at 09:43:07AM -0600, Tom Lendacky wrote:
> Add support for Secure Memory Encryption (SME). This initial support
> provides a Kconfig entry to build the SME support into the kernel and
> defines the memory encryption mask that will be used in subsequent
> patches to mark pages as encrypted.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/Kconfig                   |   22 +++++++++++++++++++
>  arch/x86/include/asm/mem_encrypt.h |   42 ++++++++++++++++++++++++++++++++++++
>  arch/x86/mm/Makefile               |    1 +
>  arch/x86/mm/mem_encrypt.c          |   21 ++++++++++++++++++
>  include/linux/mem_encrypt.h        |   37 ++++++++++++++++++++++++++++++++
>  5 files changed, 123 insertions(+)
>  create mode 100644 arch/x86/include/asm/mem_encrypt.h
>  create mode 100644 arch/x86/mm/mem_encrypt.c
>  create mode 100644 include/linux/mem_encrypt.h
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index f8fbfc5..a3b8c71 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1395,6 +1395,28 @@ config X86_DIRECT_GBPAGES
>  	  supports them), so don't confuse the user by printing
>  	  that we have them enabled.
>  
> +config AMD_MEM_ENCRYPT
> +	bool "AMD Secure Memory Encryption (SME) support"
> +	depends on X86_64 && CPU_SUP_AMD
> +	---help---
> +	  Say yes to enable support for the encryption of system memory.
> +	  This requires an AMD processor that supports Secure Memory
> +	  Encryption (SME).
> +
> +config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
> +	bool "Activate AMD Secure Memory Encryption (SME) by default"
> +	default y
> +	depends on AMD_MEM_ENCRYPT
> +	---help---
> +	  Say yes to have system memory encrypted by default if running on
> +	  an AMD processor that supports Secure Memory Encryption (SME).
> +
> +	  If set to Y, then the encryption of system memory can be
> +	  deactivated with the mem_encrypt=off command line option.
> +
> +	  If set to N, then the encryption of system memory can be
> +	  activated with the mem_encrypt=on command line option.

Good.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
