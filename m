Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 91E356B00DF
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 11:30:18 -0400 (EDT)
Date: Wed, 12 Sep 2012 17:30:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] mm: thp: Fix the pmd_clear() arguments in
 pmdp_get_and_clear()
Message-ID: <20120912153016.GS21579@dhcp22.suse.cz>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-2-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347382036-18455-2-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Steve Capper <steve.capper@arm.com>

On Tue 11-09-12 17:47:14, Will Deacon wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> The CONFIG_TRANSPARENT_HUGEPAGE implementation of pmdp_get_and_clear()
> calls pmd_clear() with 3 arguments instead of 1.

only for !__HAVE_ARCH_PMDP_GET_AND_CLEAR which doesn't seem to happen
because x86 defines this and it uses pmd_update.

> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Other than that it looks good.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
