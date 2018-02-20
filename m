Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2293B6B0003
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 18:21:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id r29so3823432wra.13
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 15:21:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g9si17856043wrc.37.2018.02.20.15.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 15:21:51 -0800 (PST)
Date: Tue, 20 Feb 2018 15:21:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: don't defer struct page initialization for Xen pv
 guests
Message-Id: <20180220152148.2a3ff03d3c8aa6ade8cbae25@linux-foundation.org>
In-Reply-To: <201802190217.ctfr9bPI%fengguang.wu@intel.com>
References: <20180216133726.30813-1-jgross@suse.com>
	<201802190217.ctfr9bPI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Juergen Gross <jgross@suse.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, mhocko@suse.com, stable@vger.kernel.org

On Mon, 19 Feb 2018 02:45:27 +0800 kbuild test robot <lkp@intel.com> wrote:

> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.16-rc1 next-20180216]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Juergen-Gross/mm-don-t-defer-struct-page-initialization-for-Xen-pv-guests/20180218-233657
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-x010-201807 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/page_alloc.c: In function 'update_defer_init':
> >> mm/page_alloc.c:352:6: error: implicit declaration of function 'xen_pv_domain' [-Werror=implicit-function-declaration]
>      if (xen_pv_domain())
>          ^~~~~~~~~~~~~

I think I already fixed this.



From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-dont-defer-struct-page-initialization-for-xen-pv-guests-fix

explicitly include xen.h

Cc: Juergen Gross <jgross@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN mm/page_alloc.c~mm-dont-defer-struct-page-initialization-for-xen-pv-guests-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-dont-defer-struct-page-initialization-for-xen-pv-guests-fix
+++ a/mm/page_alloc.c
@@ -46,6 +46,7 @@
 #include <linux/stop_machine.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
+#include <xen/xen.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
