From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 02/20] x86: Set the write-protect cache mode for
 full PAT support
Date: Thu, 10 Nov 2016 14:14:00 +0100
Message-ID: <20161110131400.bmeoojsrin2zi2w2@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003448.3280.27573.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161110003448.3280.27573.stgit@tlendack-t1.amdoffice.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>, Toshi Kani <toshi.kani@hpe.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>
List-Id: linux-mm.kvack.org

+ Toshi.

On Wed, Nov 09, 2016 at 06:34:48PM -0600, Tom Lendacky wrote:
> For processors that support PAT, set the write-protect cache mode
> (_PAGE_CACHE_MODE_WP) entry to the actual write-protect value (x05).
> 
> Acked-by: Borislav Petkov <bp@suse.de>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/mm/pat.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 170cc4f..87e8952 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -355,7 +355,7 @@ void pat_init(void)
>  		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
>  		 *      011    3    UC : _PAGE_CACHE_MODE_UC
>  		 *      100    4    WB : Reserved
> -		 *      101    5    WC : Reserved
> +		 *      101    5    WP : _PAGE_CACHE_MODE_WP
>  		 *      110    6    UC-: Reserved
>  		 *      111    7    WT : _PAGE_CACHE_MODE_WT
>  		 *
> @@ -363,7 +363,7 @@ void pat_init(void)
>  		 * corresponding types in the presence of PAT errata.
>  		 */
>  		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
> -		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
> +		      PAT(4, WB) | PAT(5, WP) | PAT(6, UC_MINUS) | PAT(7, WT);
>  	}
>  
>  	if (!boot_cpu_done) {
> 
> 

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
