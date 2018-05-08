Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C43FA6B028E
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:59:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w9-v6so7952851pgq.21
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:59:58 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id s71si13991473pfi.74.2018.05.08.07.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 07:59:57 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 0/8] mm, x86, powerpc: Consolidate pkey code
Date: Wed,  9 May 2018 00:59:40 +1000
Message-Id: <20180508145948.9492-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

This is a rework of Ram's series, which broke the build on both arches at
various points due to the differing header dependencies.

The actual pkey changes are basically the same, this just has some rework to
get the headers cleaned up a bit beforehand.

If no one objects I'll ask Stephen to put these in a topic branch in
linux-next, and I or someone else can merge them for 4.18.

cheers


Ram's original:
  http://patchwork.ozlabs.org/patch/909066/
  http://patchwork.ozlabs.org/patch/909067/
  http://patchwork.ozlabs.org/patch/909068/



Michael Ellerman (5):
  mm/pkeys: Remove include of asm/mmu_context.h from pkeys.h
  mm/pkeys, powerpc, x86: Provide an empty vma_pkey() in linux/pkeys.h
  x86/pkeys: Move vma_pkey() into asm/pkeys.h
  x86/pkeys: Add arch_pkeys_enabled()
  mm/pkeys: Add an empty arch_pkeys_enabled()

Ram Pai (3):
  mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS is
    enabled
  mm, powerpc, x86: introduce an additional vma bit for powerpc pkey
  mm/pkeys, x86, powerpc: Display pkey in smaps if arch supports pkeys

 arch/powerpc/include/asm/mmu_context.h |  5 -----
 arch/powerpc/include/asm/pkeys.h       |  2 ++
 arch/x86/include/asm/mmu_context.h     | 15 ---------------
 arch/x86/include/asm/pkeys.h           | 13 +++++++++++++
 arch/x86/kernel/setup.c                |  8 --------
 fs/proc/task_mmu.c                     | 13 +++++++------
 include/linux/mm.h                     | 12 +++++++-----
 include/linux/pkeys.h                  | 13 +++++++++++--
 8 files changed, 40 insertions(+), 41 deletions(-)

-- 
2.14.1
