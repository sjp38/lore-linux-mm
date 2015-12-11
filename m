From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 0/5] x86: KVM vdso and clock improvements
Date: Thu, 10 Dec 2015 19:20:17 -0800
Message-ID: <cover.1449702533.git.luto__5364.12004516951$1449804044$gmane$org@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1a7EFy-00026S-LW
	for glkm-linux-mm-2@m.gmane.org; Fri, 11 Dec 2015 04:20:30 +0100
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C6EA96B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:20:28 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so57743519pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:20:28 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id b8si280578pas.185.2015.12.10.19.20.27
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:20:27 -0800 (PST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

NB: patch 1 doesn't really belong here, but it makes this a lot
easier for me to test.  Patch 1, if it's okay at all, should go
though the kvm tree.  The rest should probably go through
tip:x86/vdso once they're reviewed.

I'll do a followup to enable vdso pvclock on 32-bit guests.
I'm not currently set up to test it.  (The KVM people could also
do it very easily on top of these patches.)

Andy Lutomirski (5):
  x86/kvm: On KVM re-enable (e.g. after suspend), update clocks
  x86, vdso, pvclock: Simplify and speed up the vdso pvclock reader
  x86/vdso: Get pvclock data from the vvar VMA instead of the fixmap
  x86/vdso: Remove pvclock fixmap machinery
  x86/vdso: Enable vdso pvclock access on all vdso variants

 arch/x86/entry/vdso/vclock_gettime.c  | 151 ++++++++++++++++------------------
 arch/x86/entry/vdso/vdso-layout.lds.S |   3 +-
 arch/x86/entry/vdso/vdso2c.c          |   3 +
 arch/x86/entry/vdso/vma.c             |  14 ++++
 arch/x86/include/asm/fixmap.h         |   5 --
 arch/x86/include/asm/pvclock.h        |  14 ++--
 arch/x86/include/asm/vdso.h           |   1 +
 arch/x86/kernel/kvmclock.c            |  11 ++-
 arch/x86/kernel/pvclock.c             |  24 ------
 arch/x86/kvm/x86.c                    |  75 +----------------
 10 files changed, 110 insertions(+), 191 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
