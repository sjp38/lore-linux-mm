Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 4E87D6B00D3
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 13:11:42 -0400 (EDT)
Date: Tue, 11 Sep 2012 20:12:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm: thp: Fix the pmd_clear() arguments in
 pmdp_get_and_clear()
Message-ID: <20120911171215.GA29664@shutemov.name>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-2-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347382036-18455-2-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Steve Capper <steve.capper@arm.com>

On Tue, Sep 11, 2012 at 05:47:14PM +0100, Will Deacon wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> The CONFIG_TRANSPARENT_HUGEPAGE implementation of pmdp_get_and_clear()
> calls pmd_clear() with 3 arguments instead of 1.
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>

> ---
>  include/asm-generic/pgtable.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index ff4947b..f7e0206 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -87,7 +87,7 @@ static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
>  				       pmd_t *pmdp)
>  {
>  	pmd_t pmd = *pmdp;
> -	pmd_clear(mm, address, pmdp);
> +	pmd_clear(pmdp);
>  	return pmd;
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
