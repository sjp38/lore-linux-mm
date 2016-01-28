Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E94556B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 03:46:37 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so19787716pab.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 00:46:37 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id p73si15499332pfi.236.2016.01.28.00.46.36
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 00:46:37 -0800 (PST)
Date: Thu, 28 Jan 2016 16:45:31 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 1860/2084] lib/../mm/internal.h:227:19: note: in
 expansion of macro 'VM_STACK_FLAGS'
Message-ID: <201601281630.hC33XSLR%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   888c8375131656144c1605071eab2eb6ac49abc3
commit: cec08ed70d3d5209368a435fed278ae667117a0c [1860/2084] mm, printk: introduce new format string for flags
config: frv-defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout cec08ed70d3d5209368a435fed278ae667117a0c
        # save the attached .config to linux build tree
        make.cross ARCH=frv 

All warnings (new ones prefixed by >>):

   In file included from include/linux/io.h:26:0,
                    from include/linux/clk-provider.h:14,
                    from lib/vsprintf.c:21:
   lib/../mm/internal.h: In function 'is_stack_mapping':
   arch/frv/include/asm/page.h:68:27: error: 'READ_IMPLIES_EXEC' undeclared (first use in this function)
     ((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0 ) | \
                              ^
   include/linux/mm.h:200:32: note: in expansion of macro 'VM_DATA_DEFAULT_FLAGS'
    #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
                                   ^
   include/linux/mm.h:206:40: note: in expansion of macro 'VM_STACK_DEFAULT_FLAGS'
    #define VM_STACK_FLAGS (VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
                                           ^
>> lib/../mm/internal.h:227:19: note: in expansion of macro 'VM_STACK_FLAGS'
     return (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN))) != 0;
                      ^
   arch/frv/include/asm/page.h:68:27: note: each undeclared identifier is reported only once for each function it appears in
     ((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0 ) | \
                              ^
   include/linux/mm.h:200:32: note: in expansion of macro 'VM_DATA_DEFAULT_FLAGS'
    #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
                                   ^
   include/linux/mm.h:206:40: note: in expansion of macro 'VM_STACK_DEFAULT_FLAGS'
    #define VM_STACK_FLAGS (VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
                                           ^
>> lib/../mm/internal.h:227:19: note: in expansion of macro 'VM_STACK_FLAGS'
     return (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN))) != 0;
                      ^
   lib/../mm/internal.h: In function 'is_data_mapping':
   arch/frv/include/asm/page.h:68:27: error: 'READ_IMPLIES_EXEC' undeclared (first use in this function)
     ((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0 ) | \
                              ^
   include/linux/mm.h:200:32: note: in expansion of macro 'VM_DATA_DEFAULT_FLAGS'
    #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
                                   ^
   include/linux/mm.h:206:40: note: in expansion of macro 'VM_STACK_DEFAULT_FLAGS'
    #define VM_STACK_FLAGS (VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
                                           ^
   lib/../mm/internal.h:232:20: note: in expansion of macro 'VM_STACK_FLAGS'
     return (flags & ((VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)) |
                       ^

vim +/VM_STACK_FLAGS +227 lib/../mm/internal.h

99c0fd5e Vlastimil Babka       2014-10-09  211   * use of the result.
99c0fd5e Vlastimil Babka       2014-10-09  212   */
4db0c3c2 Jason Low             2015-04-15  213  #define page_order_unsafe(page)		READ_ONCE(page_private(page))
99c0fd5e Vlastimil Babka       2014-10-09  214  
4bbd4c77 Kirill A. Shutemov    2014-06-04  215  static inline bool is_cow_mapping(vm_flags_t flags)
4bbd4c77 Kirill A. Shutemov    2014-06-04  216  {
4bbd4c77 Kirill A. Shutemov    2014-06-04  217  	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
4bbd4c77 Kirill A. Shutemov    2014-06-04  218  }
4bbd4c77 Kirill A. Shutemov    2014-06-04  219  
07dff8ae Konstantin Khlebnikov 2016-01-28  220  static inline bool is_exec_mapping(vm_flags_t flags)
07dff8ae Konstantin Khlebnikov 2016-01-28  221  {
07dff8ae Konstantin Khlebnikov 2016-01-28  222  	return (flags & (VM_EXEC | VM_WRITE)) == VM_EXEC;
07dff8ae Konstantin Khlebnikov 2016-01-28  223  }
07dff8ae Konstantin Khlebnikov 2016-01-28  224  
07dff8ae Konstantin Khlebnikov 2016-01-28  225  static inline bool is_stack_mapping(vm_flags_t flags)
07dff8ae Konstantin Khlebnikov 2016-01-28  226  {
07dff8ae Konstantin Khlebnikov 2016-01-28 @227  	return (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN))) != 0;
07dff8ae Konstantin Khlebnikov 2016-01-28  228  }
07dff8ae Konstantin Khlebnikov 2016-01-28  229  
07dff8ae Konstantin Khlebnikov 2016-01-28  230  static inline bool is_data_mapping(vm_flags_t flags)
07dff8ae Konstantin Khlebnikov 2016-01-28  231  {
07dff8ae Konstantin Khlebnikov 2016-01-28  232  	return (flags & ((VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)) |
07dff8ae Konstantin Khlebnikov 2016-01-28  233  					VM_WRITE | VM_SHARED)) == VM_WRITE;
07dff8ae Konstantin Khlebnikov 2016-01-28  234  }
07dff8ae Konstantin Khlebnikov 2016-01-28  235  

:::::: The code at line 227 was first introduced by commit
:::::: 07dff8ae2bc5c3adf387f95c4d6864b1d06866f2 mm: warn about VmData over RLIMIT_DATA

:::::: TO: Konstantin Khlebnikov <koct9i@gmail.com>
:::::: CC: Stephen Rothwell <sfr@canb.auug.org.au>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--VS++wcV0S1rZb1Fb
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
6uvK6D5tXCQK04uEDb/yf5ugy74PfAAA

--VS++wcV0S1rZb1Fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
