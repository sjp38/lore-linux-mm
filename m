Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 924F36B0007
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:53:04 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c135so2590227qkb.10
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:53:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11sor87646qtn.102.2018.02.21.15.53.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 15:53:03 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v12 0/3] mm, x86, powerpc: Enhancements to Memory Protection Keys.
Date: Wed, 21 Feb 2018 15:52:15 -0800
Message-Id: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

This patch series provides arch-neutral enhancements to
enable memory-keys on new architecutes, and the corresponding
changes in x86 and powerpc specific code to support that.

a) Provides ability to support upto 32 keys.  PowerPC
	can handle 32 keys and hence needs this.

b) Arch-neutral code; and not the arch-specific code,
   determines the format of the string, that displays the key
   for each vma in smaps.

History:
-------
version v12:
	(1) fixed compilation errors seen with various x86
		configs.
version v11:
	(1) code that displays key in smaps is not any more
		defined under CONFIG_ARCH_HAS_PKEYS.
       	    - Comment by Eric W. Biederman and Michal Hocko
	(2) merged two patches that implemented (1).
		- comment by Michal Hocko

version prior to v11:
	(1) used one additional bit from VM_HIGH_ARCH_*
       		to support 32 keys.
	    - Suggestion by Dave Hansen.
	(2) powerpc specific changes to support memory keys.

Ram Pai (3):
  mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS
    is enabled
  mm, powerpc, x86: introduce an additional vma bit for powerpc pkey
  mm, x86, powerpc: display pkey in smaps only if arch supports pkeys

 arch/powerpc/include/asm/mmu_context.h |    5 -----
 arch/x86/include/asm/mmu_context.h     |    5 -----
 arch/x86/include/asm/pkeys.h           |    1 +
 arch/x86/kernel/fpu/xstate.c           |    5 +++++
 arch/x86/kernel/setup.c                |    8 --------
 fs/proc/task_mmu.c                     |   15 ++++++++-------
 include/linux/mm.h                     |   12 +++++++-----
 include/linux/pkeys.h                  |    7 ++++++-
 8 files changed, 27 insertions(+), 31 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
