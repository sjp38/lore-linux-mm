Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E28C6B0253
	for <linux-mm@kvack.org>; Sat,  4 Feb 2017 20:03:14 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so68470295pgf.3
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 17:03:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l11si29650546plk.130.2017.02.04.17.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Feb 2017 17:03:13 -0800 (PST)
Date: Sun, 5 Feb 2017 09:02:45 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 7614/7828] ipc/shm.c:1368:3: error: too few
 arguments to function 'do_munmap'
Message-ID: <201702050936.w69pXavt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   421cf055e6a2d2d91556320781175b8050da2b7c
commit: 197b090832eaa4a6ed2e092ff8d4ab3f0511a049 [7614/7828] userfaultfd: non-cooperative: add event for memory unmaps
config: c6x-evmc6678_defconfig (attached as .config)
compiler: c6x-elf-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 197b090832eaa4a6ed2e092ff8d4ab3f0511a049
        # save the attached .config to linux build tree
        make.cross ARCH=c6x 

All errors (new ones prefixed by >>):

   ipc/shm.c: In function 'SYSC_shmdt':
>> ipc/shm.c:1368:3: error: too few arguments to function 'do_munmap'
      do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
      ^~~~~~~~~
   In file included from ipc/shm.c:28:0:
   include/linux/mm.h:2093:12: note: declared here
    extern int do_munmap(struct mm_struct *, unsigned long, size_t,
               ^~~~~~~~~
--
>> mm/nommu.c:1201:15: error: conflicting types for 'do_mmap'
    unsigned long do_mmap(struct file *file,
                  ^~~~~~~
   In file included from mm/nommu.c:19:0:
   include/linux/mm.h:2089:22: note: previous declaration of 'do_mmap' was here
    extern unsigned long do_mmap(struct file *file, unsigned long addr,
                         ^~~~~~~
>> mm/nommu.c:1580:5: error: conflicting types for 'do_munmap'
    int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
        ^~~~~~~~~
   In file included from mm/nommu.c:19:0:
   include/linux/mm.h:2093:12: note: previous declaration of 'do_munmap' was here
    extern int do_munmap(struct mm_struct *, unsigned long, size_t,
               ^~~~~~~~~
   In file included from mm/nommu.c:18:0:
   mm/nommu.c:1638:15: error: conflicting types for 'do_munmap'
    EXPORT_SYMBOL(do_munmap);
                  ^
   include/linux/export.h:58:21: note: in definition of macro '___EXPORT_SYMBOL'
     extern typeof(sym) sym;      \
                        ^~~
   mm/nommu.c:1638:1: note: in expansion of macro 'EXPORT_SYMBOL'
    EXPORT_SYMBOL(do_munmap);
    ^~~~~~~~~~~~~
   In file included from mm/nommu.c:19:0:
   include/linux/mm.h:2093:12: note: previous declaration of 'do_munmap' was here
    extern int do_munmap(struct mm_struct *, unsigned long, size_t,
               ^~~~~~~~~

vim +/do_munmap +1368 ipc/shm.c

^1da177e4 Linus Torvalds  2005-04-16  1362  
8feae1311 David Howells   2009-01-08  1363  #else	/* CONFIG_MMU */
8feae1311 David Howells   2009-01-08  1364  	/* under NOMMU conditions, the exact address to be destroyed must be
63980c80e Shailesh Pandey 2016-12-14  1365  	 * given
63980c80e Shailesh Pandey 2016-12-14  1366  	 */
530fcd16d Davidlohr Bueso 2013-09-11  1367  	if (vma && vma->vm_start == addr && vma->vm_ops == &shm_vm_ops) {
8feae1311 David Howells   2009-01-08 @1368  		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
8feae1311 David Howells   2009-01-08  1369  		retval = 0;
8feae1311 David Howells   2009-01-08  1370  	}
8feae1311 David Howells   2009-01-08  1371  

:::::: The code at line 1368 was first introduced by commit
:::::: 8feae13110d60cc6287afabc2887366b0eb226c2 NOMMU: Make VMAs per MM as for MMU-mode linux

:::::: TO: David Howells <dhowells@redhat.com>
:::::: CC: David Howells <dhowells@redhat.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--AqsLC8rIMeq19msA
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
+JYTK6LdIBg5HH7f3Nke0e3/AyY7AJWORgAA

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
