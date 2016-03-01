Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DED2B6B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 01:38:01 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so20965451wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 22:38:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m12si35776142wjr.213.2016.02.29.22.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 22:38:00 -0800 (PST)
Date: Mon, 29 Feb 2016 22:38:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mn10300, c6x: CONFIG_GENERIC_BUG must depend on CONFIG_BUG
Message-Id: <20160229223807.7d4723a0.akpm@linux-foundation.org>
In-Reply-To: <201603011418.lCbS3v2i%fengguang.wu@intel.com>
References: <20160229124937.984ac318110f686d96532088@linux-foundation.org>
	<201603011418.lCbS3v2i%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 1 Mar 2016 14:18:56 +0800 kbuild test robot <lkp@intel.com> wrote:

> [auto build test ERROR on v4.5-rc6]
> [also build test ERROR on next-20160229]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Andrew-Morton/mn10300-c6x-CONFIG_GENERIC_BUG-must-depend-on-CONFIG_BUG/20160301-045134
> config: mn10300-allnoconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=mn10300 
> 
> All errors (new ones prefixed by >>):
> 
> >> arch/mn10300/kernel/fpu-nofpu.c:27:36: error: unknown type name 'elf_fpregset_t'
>     int dump_fpu(struct pt_regs *regs, elf_fpregset_t *fpreg)

hm, that error isn't well correlated with that patch!

This, I suppose.  I don't have an mn10300 cross-compiler.



From: Andrew Morton <akpm@linux-foundation.org>
Subject: arch/mn10300/kernel/fpu-nofpu.c: needs asm/elf.h

 arch/mn10300/kernel/fpu-nofpu.c:27:36: error: unknown type name 'elf_fpregset_t'
    int dump_fpu(struct pt_regs *regs, elf_fpregset_t *fpreg)

Reported-by: kbuild test robot <lkp@intel.com>
Cc: Josh Triplett <josh@joshtriplett.org>
Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/mn10300/kernel/fpu-nofpu.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN arch/mn10300/kernel/fpu-nofpu.c~a arch/mn10300/kernel/fpu-nofpu.c
--- a/arch/mn10300/kernel/fpu-nofpu.c~a
+++ a/arch/mn10300/kernel/fpu-nofpu.c
@@ -9,6 +9,7 @@
  * 2 of the Licence, or (at your option) any later version.
  */
 #include <asm/fpu.h>
+#include <asm/elf.h>
 
 /*
  * handle an FPU operational exception
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
