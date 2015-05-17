From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 1/6] mm, x86: Simplify conditions of
 HAVE_ARCH_HUGE_VMAP
Date: Sun, 17 May 2015 10:30:39 +0200
Message-ID: <20150517083039.GA11814@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
 <1431714237-880-2-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431714237-880-2-git-send-email-toshi.kani@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com
List-Id: linux-mm.kvack.org

On Fri, May 15, 2015 at 12:23:52PM -0600, Toshi Kani wrote:
> Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
> in arch/x86/Kconfig since X86_PAE depends on X86_32.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 8fec044..73a4d03 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -100,7 +100,7 @@ config X86
>  	select IRQ_FORCED_THREADING
>  	select HAVE_BPF_JIT if X86_64
>  	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
> -	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
> +	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
>  	select ARCH_HAS_SG_CHAIN
>  	select CLKEVT_I8253
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG

Applied, thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
