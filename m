Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id E9DB46B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 15:37:53 -0400 (EDT)
Received: by qgt47 with SMTP id 47so21812780qgt.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 12:37:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b68si4175303qgf.92.2015.09.17.12.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 12:37:53 -0700 (PDT)
Date: Thu, 17 Sep 2015 12:37:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: drivers/firmware/efi/libstub/efi-stub-helper.c:599:2: warning:
 implicit declaration of function 'memcpy'
Message-Id: <20150917123751.772410664187565ba24171a5@linux-foundation.org>
In-Reply-To: <201509170954.bUogAGSu%fengguang.wu@intel.com>
References: <201509170954.bUogAGSu%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, kbuild-all@01.org, Andrey Konovalov <adech.fo@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 17 Sep 2015 09:17:56 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   72714841b705a5b9bccf37ee85a62352bee3a3ef
> commit: 393f203f5fd54421fddb1e2a263f64d3876eeadb x86_64: kasan: add interceptors for memset/memmove/memcpy functions
> date:   7 months ago
> config: i386-randconfig-i0-201537 (attached as .config)
> reproduce:
>   git checkout 393f203f5fd54421fddb1e2a263f64d3876eeadb
>   # save the attached .config to linux build tree
>   make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>    drivers/firmware/efi/libstub/efi-stub-helper.c: In function 'efi_relocate_kernel':
> >> drivers/firmware/efi/libstub/efi-stub-helper.c:599:2: warning: implicit declaration of function 'memcpy' [-Wimplicit-function-declaration]
>      memcpy((void *)new_addr, (void *)cur_image_addr, image_size);

I can't reproduce this.

But whatever.  I'll do this:

--- a/drivers/firmware/efi/libstub/efi-stub-helper.c~drivers-firmware-efi-libstub-efi-stub-helperc-needs-stringh
+++ a/drivers/firmware/efi/libstub/efi-stub-helper.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/efi.h>
+#include <linux/string.h>
 #include <asm/efi.h>
 
 #include "efistub.h"
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
