Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4710F6B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 17:26:24 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so63485476pab.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 14:26:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ix1si19803928pbd.181.2015.08.07.14.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 14:26:23 -0700 (PDT)
Date: Fri, 7 Aug 2015 14:26:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 6277/6751] mm/page_idle.c:74:4: error:
 implicit declaration of function 'pte_unmap'
Message-Id: <20150807142622.b2de8f5e70f1224dfe9aa195@linux-foundation.org>
In-Reply-To: <201508072227.PBXmgcfg%fengguang.wu@intel.com>
References: <201508072227.PBXmgcfg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 7 Aug 2015 22:24:33 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   e6455bc5b91f41f842f30465c9193320f0568707
> commit: cbba4e22584984bffccd07e0801fd2b8ec1ecf5f [6277/6751] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap
> config: blackfin-allmodconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout cbba4e22584984bffccd07e0801fd2b8ec1ecf5f
>   # save the attached .config to linux build tree
>   make.cross ARCH=blackfin 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/page_idle.c: In function 'page_idle_clear_pte_refs_one':
>    mm/page_idle.c:67:4: error: implicit declaration of function 'pmdp_test_and_clear_young' [-Werror=implicit-function-declaration]
>    mm/page_idle.c:71:3: error: implicit declaration of function 'page_check_address' [-Werror=implicit-function-declaration]

Yeah.  This?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: proc-add-kpageidle-file-fix-6-fix-2-fix

kpageidle requires an MMU

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN fs/proc/page.c~proc-add-kpageidle-file-fix-6-fix-2-fix fs/proc/page.c
diff -puN mm/Kconfig~proc-add-kpageidle-file-fix-6-fix-2-fix mm/Kconfig
--- a/mm/Kconfig~proc-add-kpageidle-file-fix-6-fix-2-fix
+++ a/mm/Kconfig
@@ -657,7 +657,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
-	depends on SYSFS
+	depends on SYSFS && MMU
 	select PAGE_EXTENSION if !64BIT
 	help
 	  This feature allows to estimate the amount of user pages that have
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
