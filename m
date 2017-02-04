Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 263CD6B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 21:27:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so44213640pfy.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 18:27:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d9si22385987pge.193.2017.02.03.18.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 18:27:37 -0800 (PST)
Date: Sat, 4 Feb 2017 10:26:37 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
Message-ID: <201702041041.pT43t4Op%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203181008.24898-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi Vlastimil,

[auto build test WARNING on mmotm/master]
[also build test WARNING on v4.10-rc6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/mm-slab-rename-kmalloc-node-cache-to-kmalloc-size/20170204-021843
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-allmodconfig
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        make ARCH=i386  allmodconfig
        make ARCH=i386 

All warnings (new ones prefixed by >>):

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
