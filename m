Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D215C6B0258
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:41 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so136763737pac.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jf11si7454995pbd.111.2015.09.08.13.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:35 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/12] userfaultfd non-x86 and selftest updates for 4.2.0+
Date: Tue,  8 Sep 2015 22:43:18 +0200
Message-Id: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Here are some pending updates for userfaultfd mostly to the self test,
the rest are cleanups.

I put 1/12 first because it was already submitted separately by
Stephen Rothwell so chances are it's already upstream.

If you had problems with the selftest on non-x86 arches please try
again with these patches applied (or if you prefer to git clone
instead of git am, give a spin to the aa.git "userfault" branch which
is in sync with this submit).

Some of these have been floating on the lists, so after this submit we
should be all in sync.

I understand the powerpc parts are to be deferred for upstream merging
(-mm mailer comment said so), so I assume the aarch64 parts too, but
they could still land in -mm and linux-next in the meantime.

NOTE: none of these changes is urgent.

The patchset is actually against upstream, if this doesn't apply clean
to -mm or you prefer it against linux-next let me know.

Thanks,
Andrea

Andrea Arcangeli (7):
  userfaultfd: selftest: update userfaultfd x86 32bit syscall number
  userfaultfd: Revert "userfaultfd: waitqueue: add nr wake parameter to
    __wake_up_locked_key"
  userfaultfd: selftest: headers fixup
  userfaultfd: selftest: avoid my_bcmp false positives with powerpc
  userfaultfd: selftest: return an error if BOUNCE_VERIFY fails
  userfaultfd: selftest: don't error out if pthread_mutex_t isn't
    identical
  userfaultfd: powerpc: implement syscall

Bharata B Rao (1):
  userfaultfd: powerpc: Bump up __NR_syscalls to account for
    __NR_userfaultfd

Dr. David Alan Gilbert (1):
  userfaultfd: register uapi generic syscall (aarch64)

Geert Uytterhoeven (1):
  userfaultfd: selftest: Fix compiler warnings on 32-bit

Michael Ellerman (1):
  userfaultfd: selftest: only warn if __NR_userfaultfd is undefined

Thierry Reding (1):
  userfaultfd: selftests: vm: pick up sanitized kernel headers

 arch/powerpc/include/asm/systbl.h        |  1 +
 arch/powerpc/include/asm/unistd.h        |  2 +-
 arch/powerpc/include/uapi/asm/unistd.h   |  1 +
 fs/userfaultfd.c                         |  8 ++---
 include/linux/wait.h                     |  5 ++-
 include/uapi/asm-generic/unistd.h        |  4 ++-
 kernel/sched/wait.c                      |  7 ++--
 net/sunrpc/sched.c                       |  2 +-
 tools/testing/selftests/vm/Makefile      |  9 +++--
 tools/testing/selftests/vm/userfaultfd.c | 61 ++++++++++++++++++--------------
 10 files changed, 57 insertions(+), 43 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
