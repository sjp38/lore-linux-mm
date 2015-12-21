Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 12A116B0005
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 17:07:06 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id cy9so23676309pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 14:07:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yu1si11505508pac.9.2015.12.21.14.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 14:07:05 -0800 (PST)
Date: Mon, 21 Dec 2015 14:07:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: arch/x86/xen/suspend.c:70:9: error: implicit declaration of
 function 'xen_pv_domain'
Message-Id: <20151221140704.e376871cd786498eb5e71352@linux-foundation.org>
In-Reply-To: <201512210015.cGubDgTR%fengguang.wu@intel.com>
References: <201512210015.cGubDgTR%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 21 Dec 2015 00:43:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> First bad commit (maybe != root cause):
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   69c37a92ddbf79d9672230f21a04580d7ac2f4c3
> commit: 71458cfc782eafe4b27656e078d379a34e472adf kernel: add support for gcc 5
> date:   1 year, 2 months ago
> config: x86_64-randconfig-x006-201551 (attached as .config)
> reproduce:
>         git checkout 71458cfc782eafe4b27656e078d379a34e472adf
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/x86/xen/suspend.c: In function 'xen_arch_pre_suspend':
> >> arch/x86/xen/suspend.c:70:9: error: implicit declaration of function 'xen_pv_domain' [-Werror=implicit-function-declaration]
>         if (xen_pv_domain())
>             ^

hm, tricky!

--- a/arch/x86/xen/suspend.c~arch-x86-xen-suspendc-include-xen-xenh
+++ a/arch/x86/xen/suspend.c
@@ -1,6 +1,7 @@
 #include <linux/types.h>
 #include <linux/tick.h>
 
+#include <xen/xen.h>
 #include <xen/interface/xen.h>
 #include <xen/grant_table.h>
 #include <xen/events.h>
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
