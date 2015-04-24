Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7FD6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 13:49:47 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so54911489pdb.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:49:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ko11si18373031pbd.257.2015.04.24.10.49.46
        for <linux-mm@kvack.org>;
        Fri, 24 Apr 2015 10:49:46 -0700 (PDT)
Date: Sat, 25 Apr 2015 01:49:18 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [memcg:since-4.0 185/259]
 arch/x86/oprofile/../../../drivers/oprofile/buffer_sync.c:229:46: sparse:
 incorrect type in argument 1 (different address spaces)
Message-ID: <201504250113.aVgLftd1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: kbuild-all@01.org, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.0
head:   c9b476738d0773d94fa2bf9c2e867ef8206fa817
commit: b2f8bd26fdd5e7869e67a5a2cbff073eb4b52895 [185/259] mm: rcu-protected get_mm_exe_file()
reproduce:
  # apt-get install sparse
  git checkout b2f8bd26fdd5e7869e67a5a2cbff073eb4b52895
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> arch/x86/oprofile/../../../drivers/oprofile/buffer_sync.c:229:46: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/oprofile/../../../drivers/oprofile/buffer_sync.c:229:46:    expected struct path *path
   arch/x86/oprofile/../../../drivers/oprofile/buffer_sync.c:229:46:    got struct path [noderef] <asn:4>*<noident>
--
>> security/tomoyo/util.c:958:51: sparse: incorrect type in argument 1 (different address spaces)
   security/tomoyo/util.c:958:51:    expected struct path *path
   security/tomoyo/util.c:958:51:    got struct path [noderef] <asn:4>*<noident>

vim +229 arch/x86/oprofile/../../../drivers/oprofile/buffer_sync.c

448678a0 Jan Blunck            2008-02-14  213  		return (unsigned long)path->dentry;
448678a0 Jan Blunck            2008-02-14  214  	get_dcookie(path, &cookie);
^1da177e Linus Torvalds        2005-04-16  215  	return cookie;
^1da177e Linus Torvalds        2005-04-16  216  }
^1da177e Linus Torvalds        2005-04-16  217  
^1da177e Linus Torvalds        2005-04-16  218  
2dd8ad81 Konstantin Khlebnikov 2012-10-08  219  /* Look up the dcookie for the task's mm->exe_file,
^1da177e Linus Torvalds        2005-04-16  220   * which corresponds loosely to "application name". This is
^1da177e Linus Torvalds        2005-04-16  221   * not strictly necessary but allows oprofile to associate
^1da177e Linus Torvalds        2005-04-16  222   * shared-library samples with particular applications
^1da177e Linus Torvalds        2005-04-16  223   */
^1da177e Linus Torvalds        2005-04-16  224  static unsigned long get_exec_dcookie(struct mm_struct *mm)
^1da177e Linus Torvalds        2005-04-16  225  {
0c0a400d John Levon            2005-06-23  226  	unsigned long cookie = NO_COOKIE;
^1da177e Linus Torvalds        2005-04-16  227  
2dd8ad81 Konstantin Khlebnikov 2012-10-08  228  	if (mm && mm->exe_file)
2dd8ad81 Konstantin Khlebnikov 2012-10-08 @229  		cookie = fast_get_dcookie(&mm->exe_file->f_path);
^1da177e Linus Torvalds        2005-04-16  230  
^1da177e Linus Torvalds        2005-04-16  231  	return cookie;
^1da177e Linus Torvalds        2005-04-16  232  }
^1da177e Linus Torvalds        2005-04-16  233  
^1da177e Linus Torvalds        2005-04-16  234  
^1da177e Linus Torvalds        2005-04-16  235  /* Convert the EIP value of a sample into a persistent dentry/offset
^1da177e Linus Torvalds        2005-04-16  236   * pair that can then be added to the global event buffer. We make
^1da177e Linus Torvalds        2005-04-16  237   * sure to do this lookup before a mm->mmap modification happens so

:::::: The code at line 229 was first introduced by commit
:::::: 2dd8ad81e31d0d36a5d448329c646ab43eb17788 mm: use mm->exe_file instead of first VM_EXECUTABLE vma->vm_file

:::::: TO: Konstantin Khlebnikov <khlebnikov@openvz.org>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
