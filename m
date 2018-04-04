Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C82156B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 03:42:51 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o2-v6so10893584plk.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 00:42:51 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m11-v6si2378216pls.337.2018.04.04.00.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 00:42:50 -0700 (PDT)
Date: Wed, 4 Apr 2018 15:42:27 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 11/11] x86/pti: leave kernel text global for !PCID
Message-ID: <201804041545.zhtcp6gi%fengguang.wu@intel.com>
References: <20180404011011.82027E0C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404011011.82027E0C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com

Hi Dave,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on tip/auto-latest]
[also build test WARNING on next-20180403]
[cannot apply to tip/x86/core v4.16]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Dave-Hansen/Use-global-pages-with-PTI/20180404-135611
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> arch/x86/mm/pti.c:286:1: sparse: symbol 'pti_clone_pmds' was not declared. Should it be static?
   arch/x86/mm/pti.c:439:6: sparse: symbol 'pti_set_kernel_image_nonglobal' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
