Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1DE800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:52:46 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id c12so10500519qtj.3
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:52:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r24sor11504355qkk.134.2018.01.22.10.52.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:52:45 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 00/24] selftests, powerpc, x86 : Memory Protection Keys
Date: Mon, 22 Jan 2018 10:51:53 -0800
Message-Id: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

Memory protection keys enable applications to protect its address space from
inadvertent access from itself.

This feature is now enabled on powerpc architecture.  The patches move the
selftests to arch neutral directory and enhances them. Verified for correctness
on powerpc and on x86 architectures(using EC2 ubuntu VM instances).

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

Thiago Jung Bauermann (3):
  selftests/vm: Fix deadlock in protection_keys.c
  selftests/powerpc: Add ptrace tests for Protection Key register
  selftests/powerpc: Add core file test for Protection Key register

 tools/testing/selftests/powerpc/include/reg.h      |    1 +
 tools/testing/selftests/powerpc/ptrace/Makefile    |    5 +-
 tools/testing/selftests/powerpc/ptrace/core-pkey.c |  438 ++++++
 .../testing/selftests/powerpc/ptrace/ptrace-pkey.c |  443 ++++++
 tools/testing/selftests/vm/Makefile                |    1 +
 tools/testing/selftests/vm/pkey-helpers.h          |  419 ++++++
 tools/testing/selftests/vm/protection_keys.c       | 1471 ++++++++++++++++++++
 tools/testing/selftests/x86/Makefile               |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h         |  223 ---
 tools/testing/selftests/x86/protection_keys.c      | 1407 -------------------
 10 files changed, 2778 insertions(+), 1632 deletions(-)
 create mode 100644 tools/testing/selftests/powerpc/ptrace/core-pkey.c
 create mode 100644 tools/testing/selftests/powerpc/ptrace/ptrace-pkey.c
 create mode 100644 tools/testing/selftests/vm/pkey-helpers.h
 create mode 100644 tools/testing/selftests/vm/protection_keys.c
 delete mode 100644 tools/testing/selftests/x86/pkey-helpers.h
 delete mode 100644 tools/testing/selftests/x86/protection_keys.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
