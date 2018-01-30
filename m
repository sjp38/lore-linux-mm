Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24F8A6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:45:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id q185so7867950qke.2
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:45:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t27sor1935884qki.141.2018.01.30.11.45.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 11:45:01 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v11 0/3] mm, x86, powerpc: Enhancements to Memory Protection Keys.
Date: Tue, 30 Jan 2018 11:44:09 -0800
Message-Id: <1517341452-11924-1-git-send-email-linuxram@us.ibm.com>
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

PowerPC implementation of memory-keys is now in powerpc/next tree.
https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git/commit/?h=next&id=92e3da3cf193fd27996909956c12a23c0333da44

History:
-------
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
  mm, x86: display pkey in smaps only if arch supports pkeys

 arch/x86/include/asm/pkeys.h |    1 +
 arch/x86/kernel/fpu/xstate.c |    5 +++++
 arch/x86/kernel/setup.c      |    8 --------
 fs/proc/task_mmu.c           |   14 +++++++-------
 include/linux/mm.h           |   12 +++++++-----
 include/linux/pkeys.h        |    6 ++++++
 6 files changed, 26 insertions(+), 20 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
