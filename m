Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B276D6B006E
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 13:40:49 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so5715784pad.37
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 10:40:49 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id jd6si35501912pbd.84.2014.12.08.10.40.45
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 10:40:48 -0800 (PST)
Date: Tue, 9 Dec 2014 02:40:09 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 10653/11539] arch/x86/ia32/audit.c:38:14: sparse:
 incompatible types for 'case' statement
Message-ID: <201412090206.Nd6JUQcF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Drysdale <drysdale@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   cf12164be498180dc466ef97194ca7755ea39f3b
commit: b4baa9e36be0651f7eb15077af5e0eff53b7691b [10653/11539] x86: hook up execveat system call
reproduce:
  # apt-get install sparse
  git checkout b4baa9e36be0651f7eb15077af5e0eff53b7691b
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   arch/x86/ia32/audit.c:38:14: sparse: undefined identifier '__NR_execveat'
>> arch/x86/ia32/audit.c:38:14: sparse: incompatible types for 'case' statement
   arch/x86/ia32/audit.c:38:14: sparse: Expected constant expression in case statement
   arch/x86/ia32/audit.c: In function 'ia32_classify_syscall':
   arch/x86/ia32/audit.c:38:7: error: '__NR_execveat' undeclared (first use in this function)
     case __NR_execveat:
          ^
   arch/x86/ia32/audit.c:38:7: note: each undeclared identifier is reported only once for each function it appears in
--
   arch/x86/kernel/audit_64.c:53:14: sparse: undefined identifier '__NR_execveat'
>> arch/x86/kernel/audit_64.c:53:14: sparse: incompatible types for 'case' statement
   arch/x86/kernel/audit_64.c:53:14: sparse: Expected constant expression in case statement
   arch/x86/kernel/audit_64.c: In function 'audit_classify_syscall':
   arch/x86/kernel/audit_64.c:53:7: error: '__NR_execveat' undeclared (first use in this function)
     case __NR_execveat:
          ^
   arch/x86/kernel/audit_64.c:53:7: note: each undeclared identifier is reported only once for each function it appears in

vim +/case +38 arch/x86/ia32/audit.c

     1	#include <asm/unistd_32.h>
     2	
   > 3	unsigned ia32_dir_class[] = {
     4	#include <asm-generic/audit_dir_write.h>
     5	~0U
     6	};
     7	
     8	unsigned ia32_chattr_class[] = {
     9	#include <asm-generic/audit_change_attr.h>
    10	~0U
    11	};
    12	
    13	unsigned ia32_write_class[] = {
    14	#include <asm-generic/audit_write.h>
    15	~0U
    16	};
    17	
    18	unsigned ia32_read_class[] = {
    19	#include <asm-generic/audit_read.h>
    20	~0U
    21	};
    22	
    23	unsigned ia32_signal_class[] = {
    24	#include <asm-generic/audit_signal.h>
    25	~0U
    26	};
    27	
    28	int ia32_classify_syscall(unsigned syscall)
    29	{
    30		switch (syscall) {
    31		case __NR_open:
    32			return 2;
    33		case __NR_openat:
    34			return 3;
    35		case __NR_socketcall:
    36			return 4;
    37		case __NR_execve:
  > 38		case __NR_execveat:
    39			return 5;
    40		default:
    41			return 1;

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
