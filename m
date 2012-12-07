Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 90A116B0062
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 10:50:27 -0500 (EST)
Date: Fri, 7 Dec 2012 15:50:18 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH, REBASED] asm-generic, mm: PTE_SPECIAL cleanup
Message-ID: <20121207155018.GD21233@arm.com>
References: <1354881321-29363-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20121207143002.GB21233@arm.com>
 <20121207144112.GA17044@otc-wbsnb-06>
MIME-Version: 1.0
In-Reply-To: <20121207144112.GA17044@otc-wbsnb-06>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Fri, Dec 07, 2012 at 02:41:12PM +0000, Kirill A. Shutemov wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index ef90d61..2b823e5 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -33,6 +33,7 @@ config ARM64
>  =09select SPARSE_IRQ
>  =09select SYSCTL_EXCEPTION_TRACE
>  =09select CLONE_BACKWARDS
> +=09select HAVE_PTE_SPECIAL
>  =09help
>  =09  ARM 64-bit (AArch64) Linux support.

Another minor thing, please keep the arm64 Kconfig selects in
alphabetical order. I know Al Viro's patch in -next didn't but I'll push
a patch to correct this.

Otherwise:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
