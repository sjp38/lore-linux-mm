Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA0E32808A1
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 12:26:09 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gt1so34500306wjc.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 09:26:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k69si3189953wmh.64.2017.02.08.09.26.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 09:26:08 -0800 (PST)
Date: Wed, 8 Feb 2017 18:26:06 +0100
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [mmotm:master 319/413]
 arch/arm64/kernel/armv8_deprecated.c:359:31: error: expected '=', ',', ';',
 'asm' or '__attribute__' before 'aarch32_check_condition'
Message-ID: <20170208172606.GI24047@wotan.suse.de>
References: <201702081815.eLXNoErj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702081815.eLXNoErj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Feb 08, 2017 at 06:46:20PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   0f654f0e7a2b2fc05d4d5896e09e8048d16d5ed9
> commit: 2ec49283a1aa37520eed1b3c8106700e56f61713 [319/413] kprobes: move kprobe declarations to asm-generic/kprobes.h
> config: arm64-allyesconfig (attached as .config)
> compiler: aarch64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 2ec49283a1aa37520eed1b3c8106700e56f61713
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm64 
> 
> All errors (new ones prefixed by >>):
> 
> >> arch/arm64/kernel/armv8_deprecated.c:359:31: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'aarch32_check_condition'

This fixes that, will send patch.

--- a/arch/arm64/kernel/armv8_deprecated.c
+++ b/arch/arm64/kernel/armv8_deprecated.c
@@ -19,6 +19,7 @@
 #include <asm/sysreg.h>
 #include <asm/system_misc.h>
 #include <asm/traps.h>
+#include <asm/kprobes.h>
 #include <linux/uaccess.h>
 #include <asm/cpufeature.h>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
