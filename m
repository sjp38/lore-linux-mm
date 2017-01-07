Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC1456B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 22:27:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so1608008996pgc.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 19:27:12 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 3si81544138pls.10.2017.01.06.19.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 19:27:12 -0800 (PST)
Date: Sat, 7 Jan 2017 11:26:42 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [memcg:cleanups/kvmalloc 2/5] net/netfilter/x_tables.c:716:59-60:
 Unneeded semicolon
Message-ID: <201701071138.c1Bc7M2t%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git cleanups/kvmalloc
head:   351a752d1cd188fbe199f7a42094af72ee90fd63
commit: e853c5eda9c6b8fa6c01f7e76cba3ff41aa13764 [2/5] treewide: use kv[mz]alloc* rather than opencoded variants


coccinelle warnings: (new ones prefixed by >>)

>> net/netfilter/x_tables.c:716:59-60: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
