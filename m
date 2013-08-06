Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 10D086B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 05:11:40 -0400 (EDT)
Message-ID: <5200BD8C.5050409@asianux.com>
Date: Tue, 06 Aug 2013 17:10:36 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/Kconfig: add MMU dependency for MIGRATION.
References: <51F9CA7D.2070506@asianux.com> <20130805073233.GB10146@dhcp22.suse.cz> <51FF6656.4070809@gmail.com> <20130805090301.GF10146@dhcp22.suse.cz> <20130805090539.GH10146@dhcp22.suse.cz> <51FF6CC2.3060308@gmail.com> <51FF6E67.80909@asianux.com>
In-Reply-To: <51FF6E67.80909@asianux.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/05/2013 05:20 PM, Chen Gang wrote:
> 
> 
> 

Sorry for my careless sending: reserving so many waste empty lines.

> MIGRATION need depend on MMU, or allmodconfig for sh architecture which
> without MMU will be fail for compiling.
> 
> The related error: 
> 
>     CC      mm/migrate.o
>   mm/migrate.c: In function 'remove_migration_pte':
>   mm/migrate.c:134:3: error: implicit declaration of function 'pmd_trans_huge' [-Werror=implicit-function-declaration]
>      if (pmd_trans_huge(*pmd))
>      ^
>   mm/migrate.c:149:2: error: implicit declaration of function 'is_swap_pte' [-Werror=implicit-function-declaration]
>     if (!is_swap_pte(pte))
>     ^
>   ...
> 
> Also need let CMA depend on MMU, or when NOMMU, if select CMA, it will
> select MIGRATION by force.
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 256bfd0..e847f19 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -245,7 +245,7 @@ config COMPACTION
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA
> +	depends on (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA) && MMU
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful in
> @@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
>  
>  config CMA
>  	bool "Contiguous Memory Allocator"
> -	depends on HAVE_MEMBLOCK
> +	depends on HAVE_MEMBLOCK && MMU
>  	select MIGRATION
>  	select MEMORY_ISOLATION
>  	help
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
