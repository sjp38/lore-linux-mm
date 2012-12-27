Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id EBAE76B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 07:16:12 -0500 (EST)
Date: Thu, 27 Dec 2012 14:16:07 +0200
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: 3.8-rc1 build failure with MIPS/SPARSEMEM
Message-ID: <20121227121607.GA7097@blackmetal.musicnaut.iki.fi>
References: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi>
 <20121226003434.GA27760@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20121226003434.GA27760@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org

Hi,

On Wed, Dec 26, 2012 at 02:34:35AM +0200, Kirill A. Shutemov wrote:
> On MIPS if SPARSEMEM is enabled we've got this:
> 
> In file included from /home/kas/git/public/linux/arch/mips/include/asm/pgtable.h:552,
>                  from include/linux/mm.h:44,
>                  from arch/mips/kernel/asm-offsets.c:14:
> include/asm-generic/pgtable.h: In function a??my_zero_pfna??:
> include/asm-generic/pgtable.h:466: error: implicit declaration of function a??page_to_sectiona??
> In file included from arch/mips/kernel/asm-offsets.c:14:
> include/linux/mm.h: At top level:
> include/linux/mm.h:738: error: conflicting types for a??page_to_sectiona??
> include/asm-generic/pgtable.h:466: note: previous implicit declaration of a??page_to_sectiona?? was here
> 
> Due header files inter-dependencies, the only way I see to fix it is
> convert my_zero_pfn() for __HAVE_COLOR_ZERO_PAGE to macros.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Thanks, this works.

Tested-by: Aaro Koskinen <aaro.koskinen@iki.fi>

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
