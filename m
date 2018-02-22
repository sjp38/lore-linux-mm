Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 421766B0011
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 20:56:14 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id l27so2838903qkj.1
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:56:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a127sor2695383qke.159.2018.02.21.17.56.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 17:56:13 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v12 00/22] selftests, powerpc, x86 : Memory Protection Keys
Date: Wed, 21 Feb 2018 17:55:19 -0800
Message-Id: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

Memory protection keys enables an application to protect its address space from
inadvertent access by its own code.

This feature is now enabled on powerpc architecture and integrated in
4.16-rc1.  The patches move the selftests to arch neutral directory
and enhance their test coverage. 

Test
----
Verified for correctness on powerpc
and on x86 architectures(using EC2 ubuntu VM instance).

History:
-------

version 12: 
	(1) fixed the offset of pkey field in the siginfo structure for
		x86_64 and powerpc. And tries to use the actual field
		if the headers have it defined.
version 11:
	(1) fixed a deadlock in the ptrace testcase.

version 10 and prior:
	(1) moved the testcase to arch neutral directory
	(2) split the changes into incremental patches.

Ram Pai (21):
  selftests/x86: Move protecton key selftest to arch neutral directory
  selftests/vm: rename all references to pkru to a generic name
  selftests/vm: move generic definitions to header file
  selftests/vm: typecast the pkey register
  selftests/vm: generic function to handle shadow key register
  selftests/vm: fix the wrong assert in pkey_disable_set()
  selftests/vm: fixed bugs in pkey_disable_clear()
  selftests/vm: clear the bits in shadow reg when a pkey is freed.
  selftests/vm: fix alloc_random_pkey() to make it really random
  selftests/vm: introduce two arch independent abstraction
  selftests/vm: pkey register should match shadow pkey
  selftests/vm: generic cleanup
  selftests/vm: powerpc implementation for generic abstraction
  selftests/vm: clear the bits in shadow reg when a pkey is freed.
  selftests/vm: powerpc implementation to check support for pkey
  selftests/vm: fix an assertion in test_pkey_alloc_exhaust()
  selftests/vm: associate key on a mapped page and detect access
    violation
  selftests/vm: associate key on a mapped page and detect write
    violation
  selftests/vm: detect write violation on a mapped access-denied-key
    page
  selftests/vm: testcases must restore pkey-permissions
  selftests/vm: sub-page allocator

Thiago Jung Bauermann (1):
  selftests/vm: Fix deadlock in protection_keys.c

 tools/testing/selftests/vm/Makefile           |    1 +
 tools/testing/selftests/vm/pkey-helpers.h     |  434 ++++++++
 tools/testing/selftests/vm/protection_keys.c  | 1471 +++++++++++++++++++++++++
 tools/testing/selftests/x86/Makefile          |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  223 ----
 tools/testing/selftests/x86/protection_keys.c | 1407 -----------------------
 6 files changed, 1907 insertions(+), 1631 deletions(-)
 create mode 100644 tools/testing/selftests/vm/pkey-helpers.h
 create mode 100644 tools/testing/selftests/vm/protection_keys.c
 delete mode 100644 tools/testing/selftests/x86/pkey-helpers.h
 delete mode 100644 tools/testing/selftests/x86/protection_keys.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
