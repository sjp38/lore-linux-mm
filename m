Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A5DBC6B0038
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:25:26 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so26363420wiv.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 07:25:26 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id m2si13569498wif.10.2015.02.24.07.25.23
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 07:25:23 -0800 (PST)
From: Daniel Sanders <daniel.sanders@imgtec.com>
Subject: [PATCH v2 0/4] MIPS: LLVMLinux: Patches to enable compilation of a working kernel for MIPS using Clang/LLVM
Date: Tue, 24 Feb 2015 15:25:07 +0000
Message-ID: <1424791511-11407-1-git-send-email-daniel.sanders@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Daniel Sanders <daniel.sanders@imgtec.com>, Toma Tabacu <toma.tabacu@imgtec.com>, "Steven J. Hill" <Steven.Hill@imgtec.com>, Andreas Herrmann <andreas.herrmann@caviumnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Daney <david.daney@cavium.com>, David Rientjes <rientjes@google.com>, Jim Quinlan <jim2101024@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Manuel Lauss <manuel.lauss@gmail.com>, Markos Chandras <markos.chandras@imgtec.com>, Paul Bolle <pebolle@tiscali.nl>, Paul Burton <paul.burton@imgtec.com>, Pekka Enberg <penberg@kernel.org>, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org

When combined with 'MIPS: Changed current_thread_info() to an equivalent ...'
(http://www.linux-mips.org/archives/linux-mips/2015-01/msg00070.html) and the
target independent LLVMLinux patches, this patch series makes it possible to
compile a working kernel for MIPS using Clang.

The patches aren't inter-dependent so they can be merged individually or I can
split the series into individual submissions if that's preferred.

Daniel Sanders (2):
  slab: Correct size_index table before replacing the bootstrap
    kmem_cache_node.
  MIPS: LLVMLinux: Fix an 'inline asm input/output type mismatch' error.

Toma Tabacu (2):
  MIPS: LLVMLinux: Fix a 'cast to type not present in union' error.
  MIPS: LLVMLinux: Silence variable self-assignment warnings.

This series previously included a 5th patch ('MIPS: LLVMLinux: Silence unicode
warnings when preprocessing assembly.'. This patch has been dropped from this
series while we work on preventing the warnings in a different way.

 arch/mips/include/asm/checksum.h |  6 ++++--
 arch/mips/kernel/branch.c        |  6 ++++--
 arch/mips/math-emu/dp_add.c      |  5 -----
 arch/mips/math-emu/dp_sub.c      |  5 -----
 arch/mips/math-emu/sp_add.c      |  5 -----
 arch/mips/math-emu/sp_sub.c      |  5 -----
 mm/slab.c                        |  1 +
 mm/slab.h                        |  1 +
 mm/slab_common.c                 | 36 +++++++++++++++++++++---------------
 mm/slub.c                        |  1 +
 10 files changed, 32 insertions(+), 39 deletions(-)

Signed-off-by: Toma Tabacu <toma.tabacu@imgtec.com>
Signed-off-by: Daniel Sanders <daniel.sanders@imgtec.com>
Cc: "Steven J. Hill" <Steven.Hill@imgtec.com>
Cc: Andreas Herrmann <andreas.herrmann@caviumnetworks.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Daney <david.daney@cavium.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Jim Quinlan <jim2101024@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: Manuel Lauss <manuel.lauss@gmail.com>
Cc: Markos Chandras <markos.chandras@imgtec.com>
Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Paul Burton <paul.burton@imgtec.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-mm@kvack.org

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
