Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 411886B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:25:37 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ca5so71062327pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 14:25:37 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id h8si14179721pan.228.2016.07.28.14.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 14:25:36 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH 0/7] char/random: Simplify random address requests
Date: Thu, 28 Jul 2016 20:47:23 +0000
Message-Id: <20160728204730.27453-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: william.c.roberts@intel.com, Yann Droneaud <ydroneaud@opteya.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, tytso@mit.edu, arnd@arndb.de, gregkh@linuxfoundation.org, catalin.marinas@arm.com, will.deacon@arm.com, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, nnk@google.com, jeffv@google.com, dcashman@android.com, Jason Cooper <jason@lakedaemon.net>

Two previous attempts have been made to rework this API.  The first can be
found at:

  https://lkml.kernel.org/r/cover.1390770607.git.ydroneaud@opteya.com

The second at:

  https://lkml.kernel.org/r/1469471141-25669-1-git-send-email-william.c.roberts@intel.com

The RFC version of this series can been seen at:

  https://lkml.kernel.org/r/20160726030201.6775-1-jason@lakedaemon.net

In addition to incorporating ideas from these two previous efforts, this series
adds several desirable features.  First, we take the range as an argument
directly, which removes math both before the call and inside the function.
Second, we return the start address on error.  All callers fell back to the
start address on error, so we remove the need to check for errors.  Third, we
cap range to prevent overflow.  Last, we use kerneldoc to describe the new
function.

If possible, I'd like to request Acks from the various subsystems so that we
can merge this as one bisectable branch.

Jason Cooper (7):
  random: Simplify API for random address requests
  x86: Use simpler API for random address requests
  ARM: Use simpler API for random address requests
  arm64: Use simpler API for random address requests
  tile: Use simpler API for random address requests
  unicore32: Use simpler API for random address requests
  random: Remove unused randomize_range()

 arch/arm/kernel/process.c       |  3 +--
 arch/arm64/kernel/process.c     |  8 ++------
 arch/tile/mm/mmap.c             |  3 +--
 arch/unicore32/kernel/process.c |  3 +--
 arch/x86/kernel/process.c       |  3 +--
 arch/x86/kernel/sys_x86_64.c    |  5 +----
 drivers/char/random.c           | 29 ++++++++++++++++++-----------
 include/linux/random.h          |  2 +-
 8 files changed, 26 insertions(+), 30 deletions(-)

-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
