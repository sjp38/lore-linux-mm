Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id AA3146B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 01:19:56 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id l6so9340428pfl.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 22:19:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w9si9399279pfi.224.2016.02.29.22.19.55
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 22:19:55 -0800 (PST)
Date: Tue, 1 Mar 2016 14:18:56 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: mn10300, c6x: CONFIG_GENERIC_BUG must depend on CONFIG_BUG
Message-ID: <201603011418.lCbS3v2i%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
In-Reply-To: <20160229124937.984ac318110f686d96532088@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

[auto build test ERROR on v4.5-rc6]
[also build test ERROR on next-20160229]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Andrew-Morton/mn10300-c6x-CONFIG_GENERIC_BUG-must-depend-on-CONFIG_BUG/20160301-045134
config: mn10300-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=mn10300 

All errors (new ones prefixed by >>):

>> arch/mn10300/kernel/fpu-nofpu.c:27:36: error: unknown type name 'elf_fpregset_t'
    int dump_fpu(struct pt_regs *regs, elf_fpregset_t *fpreg)
                                       ^

vim +/elf_fpregset_t +27 arch/mn10300/kernel/fpu-nofpu.c

278d91c4 Akira Takeuchi 2010-10-27  11  #include <asm/fpu.h>
278d91c4 Akira Takeuchi 2010-10-27  12  
278d91c4 Akira Takeuchi 2010-10-27  13  /*
278d91c4 Akira Takeuchi 2010-10-27  14   * handle an FPU operational exception
278d91c4 Akira Takeuchi 2010-10-27  15   * - there's a possibility that if the FPU is asynchronous, the signal might
278d91c4 Akira Takeuchi 2010-10-27  16   *   be meant for a process other than the current one
278d91c4 Akira Takeuchi 2010-10-27  17   */
278d91c4 Akira Takeuchi 2010-10-27  18  asmlinkage
278d91c4 Akira Takeuchi 2010-10-27  19  void unexpected_fpu_exception(struct pt_regs *regs, enum exception_code code)
278d91c4 Akira Takeuchi 2010-10-27  20  {
278d91c4 Akira Takeuchi 2010-10-27  21  	panic("An FPU exception was received, but there's no FPU enabled.");
278d91c4 Akira Takeuchi 2010-10-27  22  }
278d91c4 Akira Takeuchi 2010-10-27  23  
278d91c4 Akira Takeuchi 2010-10-27  24  /*
278d91c4 Akira Takeuchi 2010-10-27  25   * fill in the FPU structure for a core dump
278d91c4 Akira Takeuchi 2010-10-27  26   */
278d91c4 Akira Takeuchi 2010-10-27 @27  int dump_fpu(struct pt_regs *regs, elf_fpregset_t *fpreg)
278d91c4 Akira Takeuchi 2010-10-27  28  {
278d91c4 Akira Takeuchi 2010-10-27  29  	return 0; /* not valid */
278d91c4 Akira Takeuchi 2010-10-27  30  }

:::::: The code at line 27 was first introduced by commit
:::::: 278d91c4609d55202c1e63d5fc5f01466cc7bbab MN10300: Make the FPU operate in non-lazy mode under SMP

:::::: TO: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
:::::: CC: David Howells <dhowells@redhat.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/04w6evG8XlLl3ft
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
