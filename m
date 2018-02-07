Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CED416B02F2
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 05:03:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c22so190329pfj.2
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 02:03:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l20si745698pgc.451.2018.02.07.02.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 02:03:54 -0800 (PST)
Date: Wed, 7 Feb 2018 18:03:39 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/6] Protectable Memory
Message-ID: <201802071736.PLMzjgWI%fengguang.wu@intel.com>
References: <20180204164732.28241-5-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Content-Disposition: inline
In-Reply-To: <20180204164732.28241-5-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: kbuild-all@01.org, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Igor,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on kees/for-next/pstore]
[also build test ERROR on v4.15]
[cannot apply to linus/master mmotm/master next-20180206]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/mm-security-ro-protection-for-dynamic-data/20180207-171252
base:   https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git for-next/pstore
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-review/Igor-Stoppa/mm-security-ro-protection-for-dynamic-data/20180207-171252 HEAD 99d0cb7905216da7595ef08a781a9be16a8ce687 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

>> mm/pmalloc.c:24:10: fatal error: pmalloc-selftest.h: No such file or directory
    #include "pmalloc-selftest.h"
             ^~~~~~~~~~~~~~~~~~~~
   compilation terminated.

vim +24 mm/pmalloc.c

    23	
  > 24	#include "pmalloc-selftest.h"
    25	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--d6Gm4EdcadzBjdND
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AAA=

--d6Gm4EdcadzBjdND--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
