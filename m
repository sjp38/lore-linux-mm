Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 804EA6B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 22:37:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q11so4225139pff.19
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 19:37:37 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bc9-v6si5349680plb.12.2018.02.19.19.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 19:37:36 -0800 (PST)
Date: Tue, 20 Feb 2018 11:37:08 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
Message-ID: <201802201156.4Z60eDwx%fengguang.wu@intel.com>
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: kbuild-all@01.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

Hi Souptick,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on mmotm/master]
[also build test WARNING on v4.16-rc2 next-20180219]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Souptick-Joarder/mm-zsmalloc-Replace-return-type-int-with-bool/20180220-070147
base:   git://git.cmpxchg.org/linux-mmotm.git master


coccinelle warnings: (new ones prefixed by >>)

>> mm/zsmalloc.c:309:65-66: WARNING: return of 0/1 in function 'zs_register_migration' with return type bool

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
