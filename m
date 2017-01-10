Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5157A6B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 06:34:54 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 127so721444428pfg.5
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 03:34:54 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t7si1875171pfi.147.2017.01.10.03.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 03:34:53 -0800 (PST)
Date: Tue, 10 Jan 2017 19:34:11 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 2814/2850] lib/radix-tree.c:1947:3: error: too
 few arguments to function '__radix_tree_delete_node'
Message-ID: <201701101947.a1DqdYFX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   7a399e4b4bf5368a43427bdc7541655702aced47
commit: fa06219c337a2822fc969dd68cfa93e1d244283b [2814/2850] Reimplement IDR and IDA using the radix tree
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout fa06219c337a2822fc969dd68cfa93e1d244283b
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-next/master HEAD 7a399e4b4bf5368a43427bdc7541655702aced47 builds fine.
      It may have been fixed somewhere.

All errors (new ones prefixed by >>):

   lib/radix-tree.c: In function 'radix_tree_iter_delete':
>> lib/radix-tree.c:1947:3: error: too few arguments to function '__radix_tree_delete_node'
      __radix_tree_delete_node(root, node);
      ^~~~~~~~~~~~~~~~~~~~~~~~
   lib/radix-tree.c:1931:6: note: declared here
    void __radix_tree_delete_node(struct radix_tree_root *root,
         ^~~~~~~~~~~~~~~~~~~~~~~~

vim +/__radix_tree_delete_node +1947 lib/radix-tree.c

  1941	{
  1942		struct radix_tree_node *node = iter->node;
  1943	
  1944		if (node) {
  1945			node->slots[iter_offset(iter)] = NULL;
  1946			node->count--;
> 1947			__radix_tree_delete_node(root, node);
  1948		} else {
  1949			root->rnode = NULL;
  1950		}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--fdj2RfSjLxBAspz7
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--fdj2RfSjLxBAspz7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
