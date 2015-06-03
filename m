Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 86B07900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 23:20:22 -0400 (EDT)
Received: by payr10 with SMTP id r10so64021525pay.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 20:20:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 11si27851369pda.42.2015.06.02.20.20.21
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 20:20:21 -0700 (PDT)
Date: Wed, 3 Jun 2015 11:19:37 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: mm/page_owner.c:217:1-3: WARNING: PTR_ERR_OR_ZERO can be used
Message-ID: <201506031130.vEiITJ7b%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   8cd9234c64c584432f6992fe944ca9e46ca8ea76
commit: 48c96a3685795e52903e60c7ee115e5e22e7d640 mm/page_owner: keep track of page owners
date:   6 months ago


coccinelle warnings: (new ones prefixed by >>)

>> mm/page_owner.c:217:1-3: WARNING: PTR_ERR_OR_ZERO can be used

vim +217 mm/page_owner.c

   201	
   202	static const struct file_operations proc_page_owner_operations = {
   203		.read		= read_page_owner,
   204	};
   205	
   206	static int __init pageowner_init(void)
   207	{
   208		struct dentry *dentry;
   209	
   210		if (!page_owner_inited) {
   211			pr_info("page_owner is disabled\n");
   212			return 0;
   213		}
   214	
   215		dentry = debugfs_create_file("page_owner", S_IRUSR, NULL,
   216				NULL, &proc_page_owner_operations);
 > 217		if (IS_ERR(dentry))
   218			return PTR_ERR(dentry);
   219	
   220		return 0;
   221	}
   222	module_init(pageowner_init)

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
