Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 4BDD96B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 03:54:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 4 Aug 2013 13:18:39 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E4319E0053
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 13:24:48 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r747tlhu36896798
	for <linux-mm@kvack.org>; Sun, 4 Aug 2013 13:25:47 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r747sa0Z029185
	for <linux-mm@kvack.org>; Sun, 4 Aug 2013 17:54:36 +1000
Date: Sun, 4 Aug 2013 15:54:34 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] MM: Make Contiguous Memory Allocator depends on MMU
Message-ID: <20130804075434.GA10603@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manjunath Goudar <manjunath.goudar@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, patches@linaro.org, arnd@linaro.org, dsaxena@linaro.org, linaro-kernel@lists.linaro.org, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Aug 04, 2013 at 10:41:01AM +0530, Manjunath Goudar wrote:
>s patch adds a Kconfig dependency on an MMU being available before
>CMA can be enabled.  Without this patch, CMA can be enabled on an
>MMU-less system which can lead to issues. This was discovered during
>randconfig testing, in which CMA was enabled w/o MMU being enabled,
>leading to the following error:
>
> CC      mm/migrate.o
>mm/migrate.c: In function a??remove_migration_ptea??:
>mm/migrate.c:134:3: error: implicit declaration of function a??pmd_trans_hugea??
>[-Werror=implicit-function-declaration]
>   if (pmd_trans_huge(*pmd))
>   ^
>mm/migrate.c:137:3: error: implicit declaration of function a??pte_offset_mapa??
>[-Werror=implicit-function-declaration]
>   ptep = pte_offset_map(pmd, addr);
>

Similar one.

http://marc.info/?l=linux-mm&m=137532486405085&w=2

>Signed-off-by: Manjunath Goudar <manjunath.goudar@linaro.org>
>Acked-by: Arnd Bergmann <arnd@linaro.org>
>Cc: Deepak Saxena <dsaxena@linaro.org>
>Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
>Cc: Hirokazu Takahashi <taka@valinux.co.jp>
>Cc: Dave Hansen <haveblue@us.ibm.com>
>Cc: linux-mm@kvack.org
>Cc: Johannes Weiner <hannes@cmpxchg.org>
>Cc: Michal Hocko <mhocko@suse.cz>
>Cc: Balbir Singh <bsingharora@gmail.com>
>Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>---
> mm/Kconfig |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/Kconfig b/mm/Kconfig
>index 256bfd0..ad6b98e 100644
>--- a/mm/Kconfig
>+++ b/mm/Kconfig
>@@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
>
> config CMA
> 	bool "Contiguous Memory Allocator"
>-	depends on HAVE_MEMBLOCK
>+	depends on MMU && HAVE_MEMBLOCK
> 	select MIGRATION
> 	select MEMORY_ISOLATION
> 	help
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
