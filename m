Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5C96B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:02:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so174538320pfx.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:02:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cz10si4516279pad.214.2016.07.14.13.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 13:02:02 -0700 (PDT)
Date: Thu, 14 Jul 2016 13:02:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 9661/9894] arch/x86/xen/enlighten.c:1328:2:
 note: in expansion of macro 'if'
Message-Id: <20160714130201.672b5735eff170758756d60a@linux-foundation.org>
In-Reply-To: <201607141941.aof4pvNe%fengguang.wu@intel.com>
References: <201607141941.aof4pvNe%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Petr Tesarik <ptesarik@suse.com>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 14 Jul 2016 19:39:43 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   fd8d43a58dacbbde8beaaecbeaed7bd8bdbe6859
> commit: 01eff0378a46a33a1252f9a3a4817263e16f52c0 [9661/9894] kexec: allow kdump with crash_kexec_post_notifiers
> config: x86_64-randconfig-i0-201628 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         git checkout 01eff0378a46a33a1252f9a3a4817263e16f52c0
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/ioport.h:12:0,
>                     from include/linux/device.h:16,
>                     from include/linux/node.h:17,
>                     from include/linux/cpu.h:16,
>                     from arch/x86/xen/enlighten.c:14:
>    arch/x86/xen/enlighten.c: In function 'xen_panic_event':
>    arch/x86/xen/enlighten.c:1328:7: error: implicit declaration of function 'kexec_crash_loaded' [-Werror=implicit-function-declaration]
>      if (!kexec_crash_loaded())

--- a/arch/x86/xen/enlighten.c~allow-kdump-with-crash_kexec_post_notifiers-fix
+++ a/arch/x86/xen/enlighten.c
@@ -34,9 +34,7 @@
 #include <linux/edd.h>
 #include <linux/frame.h>
 
-#ifdef CONFIG_KEXEC_CORE
 #include <linux/kexec.h>
-#endif
 
 #include <xen/xen.h>
 #include <xen/events.h>
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
