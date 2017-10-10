Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9416B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:54:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d28so24267391pfe.2
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:54:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 1si6221914pli.36.2017.10.10.14.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 14:54:28 -0700 (PDT)
Date: Wed, 11 Oct 2017 05:53:27 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 2/3] Makefile: support flag
 -fsanitizer-coverage=trace-cmp
Message-ID: <201710110522.vmKt9IJS%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20171009150521.82775-2-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, mark.rutland@arm.com, alex.popov@linux.com, aryabinin@virtuozzo.com, quentin.casasnovas@oracle.com, dvyukov@google.com, andreyknvl@google.com, keescook@chromium.org, vegard.nossum@oracle.com, syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Victor,

[auto build test ERROR on linus/master]
[also build test ERROR on v4.14-rc4]
[cannot apply to next-20171009]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Potapenko/kcov-support-comparison-operands-collection/20171011-052025
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

>> Makefile:825: scripts/Makefile.kcov: No such file or directory
>> make[1]: *** No rule to make target 'scripts/Makefile.kcov'.
   make[1]: Failed to remake makefile 'scripts/Makefile.kcov'.
>> Makefile:825: scripts/Makefile.kcov: No such file or directory
>> make[1]: *** No rule to make target 'scripts/Makefile.kcov'.
   make[1]: Failed to remake makefile 'scripts/Makefile.kcov'.
   make: *** [sub-make] Error 2

vim +825 Makefile

   823	
   824	include scripts/Makefile.kasan
 > 825	include scripts/Makefile.kcov
   826	include scripts/Makefile.extrawarn
   827	include scripts/Makefile.ubsan
   828	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--zYM0uCDKw75PZbzx
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--zYM0uCDKw75PZbzx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
