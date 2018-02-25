Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC4E46B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 21:33:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e126so6357052pfh.4
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 18:33:39 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z124si3659113pgb.811.2018.02.24.18.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Feb 2018 18:33:38 -0800 (PST)
Date: Sun, 25 Feb 2018 10:33:21 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/7] Protectable Memory
Message-ID: <201802251005.338ZhiMt%fengguang.wu@intel.com>
References: <20180223144807.1180-5-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Content-Disposition: inline
In-Reply-To: <20180223144807.1180-5-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: kbuild-all@01.org, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Igor,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.16-rc2]
[cannot apply to next-20180223]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/genalloc-track-beginning-of-allocations/20180225-081601
config: arm-allnoconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   mm/pmalloc.o: In function `pmalloc_prealloc':
>> pmalloc.c:(.text+0x280): undefined reference to `vfree_atomic'
   mm/pmalloc.o: In function `pmalloc':
   pmalloc.c:(.text+0x2c4): undefined reference to `vfree_atomic'
   mm/pmalloc.o: In function `pmalloc_chunk_free':
   pmalloc.c:(.text+0x9e): undefined reference to `vfree_atomic'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--8t9RHnE3ZwKMSgU+
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
9M1+OVRwZo6oLZMB/f8Aeda4nWJTAAA=

--8t9RHnE3ZwKMSgU+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
