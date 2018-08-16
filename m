Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE6B6B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:15:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id w14-v6so1707089pfn.13
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 00:15:27 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p81-v6si27145046pfi.345.2018.08.16.00.15.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 00:15:26 -0700 (PDT)
Date: Thu, 16 Aug 2018 15:15:02 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v3 2/3] x86/modules: Increase randomization for modules
Message-ID: <201808161516.1Wjg2efl%fengguang.wu@intel.com>
References: <1534365020-18943-3-git-send-email-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <1534365020-18943-3-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: kbuild-all@01.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org, kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Rick,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.18 next-20180815]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Rick-Edgecombe/KASLR-feature-to-randomize-each-loadable-module/20180816-120750
config: um-x86_64_defconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=um SUBARCH=x86_64

Note: the linux-review/Rick-Edgecombe/KASLR-feature-to-randomize-each-loadable-module/20180816-120750 HEAD 7eff11788897c8579f53bc7043f854794dbad25f builds fine.
      It only hurts bisectibility.

All error/warnings (new ones prefixed by >>):

   arch/x86/um/../kernel/module.c: In function 'kaslr_randomize_each_module':
>> arch/x86/um/../kernel/module.c:53:9: error: implicit declaration of function 'kaslr_enabled' [-Werror=implicit-function-declaration]
     return kaslr_enabled()
            ^~~~~~~~~~~~~
   arch/x86/um/../kernel/module.c: In function 'get_modules_rand_len':
>> arch/x86/um/../kernel/module.c:68:9: error: 'MODULES_RAND_LEN' undeclared (first use in this function); did you mean 'MODULE_NAME_LEN'?
     return MODULES_RAND_LEN;
            ^~~~~~~~~~~~~~~~
            MODULE_NAME_LEN
   arch/x86/um/../kernel/module.c:68:9: note: each undeclared identifier is reported only once for each function it appears in
>> arch/x86/um/../kernel/module.c:69:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors

vim +/kaslr_enabled +53 arch/x86/um/../kernel/module.c

    50	
    51	static inline int kaslr_randomize_each_module(void)
    52	{
  > 53		return kaslr_enabled()
    54				&& IS_ENABLED(CONFIG_RANDOMIZE_BASE)
    55				&& IS_ENABLED(CONFIG_X86_64);
    56	}
    57	
    58	static inline int kaslr_randomize_base(void)
    59	{
    60		return kaslr_enabled()
    61				&& IS_ENABLED(CONFIG_RANDOMIZE_BASE)
    62				&& !IS_ENABLED(CONFIG_X86_64);
    63	}
    64	
    65	#ifdef CONFIG_X86_64
    66	static inline const unsigned long get_modules_rand_len(void)
    67	{
  > 68		return MODULES_RAND_LEN;
  > 69	}
    70	#else
    71	static inline const unsigned long get_modules_rand_len(void)
    72	{
    73		BUILD_BUG();
    74		return 0;
    75	}
    76	#endif
    77	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--NzB8fVQJ5HfG6fxh
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
lcIXUy2FSu/bi5n+Bw2F0vZWcgAA

--NzB8fVQJ5HfG6fxh--
