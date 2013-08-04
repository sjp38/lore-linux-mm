Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 95DED6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 04:09:58 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id c13so1037400eek.5
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 01:09:56 -0700 (PDT)
Date: Sun, 4 Aug 2013 10:09:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] MM: Make Contiguous Memory Allocator depends on MMU
Message-ID: <20130804080954.GB24005@dhcp22.suse.cz>
References: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manjunath Goudar <manjunath.goudar@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, patches@linaro.org, arnd@linaro.org, dsaxena@linaro.org, linaro-kernel@lists.linaro.org, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun 04-08-13 10:41:01, Manjunath Goudar wrote:
> s patch adds a Kconfig dependency on an MMU being available before
> CMA can be enabled.  Without this patch, CMA can be enabled on an
> MMU-less system which can lead to issues. This was discovered during
> randconfig testing, in which CMA was enabled w/o MMU being enabled,
> leading to the following error:
> 
>  CC      mm/migrate.o
> mm/migrate.c: In function a??remove_migration_ptea??:
> mm/migrate.c:134:3: error: implicit declaration of function a??pmd_trans_hugea??
> [-Werror=implicit-function-declaration]
>    if (pmd_trans_huge(*pmd))
>    ^
> mm/migrate.c:137:3: error: implicit declaration of function a??pte_offset_mapa??
> [-Werror=implicit-function-declaration]
>    ptep = pte_offset_map(pmd, addr);

This is a migration code but you are updating configuration for CMA
which doesn't make much sense to me.
I guess you wanted to disable migration for CMA instead?

> Signed-off-by: Manjunath Goudar <manjunath.goudar@linaro.org>
> Acked-by: Arnd Bergmann <arnd@linaro.org>
> Cc: Deepak Saxena <dsaxena@linaro.org>
> Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
> Cc: Hirokazu Takahashi <taka@valinux.co.jp>
> Cc: Dave Hansen <haveblue@us.ibm.com>
> Cc: linux-mm@kvack.org
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 256bfd0..ad6b98e 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
>  
>  config CMA
>  	bool "Contiguous Memory Allocator"
> -	depends on HAVE_MEMBLOCK
> +	depends on MMU && HAVE_MEMBLOCK
>  	select MIGRATION
>  	select MEMORY_ISOLATION
>  	help
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
