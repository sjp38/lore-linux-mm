Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 669D66B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 21:41:01 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so11634410pac.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:41:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id be8si1292781pdb.118.2015.03.24.18.41.00
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 18:41:00 -0700 (PDT)
Date: Wed, 25 Mar 2015 09:40:22 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 401/458] fs/adfs/super.c:471 adfs_fill_super() error:
 potential null dereference 'asb->s_map'.  (adfs_read_map returns null)
Message-ID: <201503250918.zQGxJL4r%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sanidhya Kashyap <sanidhya.gatech@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   e077e8e0158533bb824f3e2d9c0eaaaf4679b0ca
commit: 4c21b0fd037c3174eeb5a9fbf620063c0192a369 [401/458] adfs: return correct return values

fs/adfs/super.c:471 adfs_fill_super() error: potential null dereference 'asb->s_map'.  (adfs_read_map returns null)

vim +471 fs/adfs/super.c

^1da177e Linus Torvalds   2005-04-16  455  	asb->s_version 		= dr->format_version;
^1da177e Linus Torvalds   2005-04-16  456  	asb->s_log2sharesize	= dr->log2sharesize;
^1da177e Linus Torvalds   2005-04-16  457  
^1da177e Linus Torvalds   2005-04-16  458  	asb->s_map = adfs_read_map(sb, dr);
4c21b0fd Sanidhya Kashyap 2015-03-25  459  	if (IS_ERR(asb->s_map)) {
4c21b0fd Sanidhya Kashyap 2015-03-25  460  		ret =  PTR_ERR(asb->s_map);
^1da177e Linus Torvalds   2005-04-16  461  		goto error_free_bh;
4c21b0fd Sanidhya Kashyap 2015-03-25  462  	}
^1da177e Linus Torvalds   2005-04-16  463  
^1da177e Linus Torvalds   2005-04-16  464  	brelse(bh);
^1da177e Linus Torvalds   2005-04-16  465  
^1da177e Linus Torvalds   2005-04-16  466  	/*
^1da177e Linus Torvalds   2005-04-16  467  	 * set up enough so that we can read an inode
^1da177e Linus Torvalds   2005-04-16  468  	 */
^1da177e Linus Torvalds   2005-04-16  469  	sb->s_op = &adfs_sops;
^1da177e Linus Torvalds   2005-04-16  470  
^1da177e Linus Torvalds   2005-04-16 @471  	dr = (struct adfs_discrecord *)(asb->s_map[0].dm_bh->b_data + 4);
^1da177e Linus Torvalds   2005-04-16  472  
^1da177e Linus Torvalds   2005-04-16  473  	root_obj.parent_id = root_obj.file_id = le32_to_cpu(dr->root);
^1da177e Linus Torvalds   2005-04-16  474  	root_obj.name_len  = 0;
da23ef05 Stuart Swales    2011-03-22  475  	/* Set root object date as 01 Jan 1987 00:00:00 */
da23ef05 Stuart Swales    2011-03-22  476  	root_obj.loadaddr  = 0xfff0003f;
da23ef05 Stuart Swales    2011-03-22  477  	root_obj.execaddr  = 0xec22c000;
^1da177e Linus Torvalds   2005-04-16  478  	root_obj.size	   = ADFS_NEWDIR_SIZE;
^1da177e Linus Torvalds   2005-04-16  479  	root_obj.attr	   = ADFS_NDA_DIRECTORY   | ADFS_NDA_OWNER_READ |

:::::: The code at line 471 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
