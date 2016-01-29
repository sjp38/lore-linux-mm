Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 26BFD6B025B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:43:04 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id uo6so46883364pac.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:43:04 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id ks7si3927262pab.129.2016.01.29.11.43.03
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 11:43:03 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 0/3] x86/mm: INVPCID support
Date: Fri, 29 Jan 2016 11:42:56 -0800
Message-Id: <cover.1454096309.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>

Boris, I think you already have these prerequisites queued up:

http://lkml.kernel.org/g/1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com
http://lkml.kernel.org/g/1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com

This is a straightforward speedup on Ivy Bridge and newer, IIRC.
(I tested on Skylake.  INVPCID is not available on Sandy Bridge.
I don't have Ivy Bridge, Haswell or Broadwell to test on, so I
could be wrong as to when the feature was introduced.)

I think we should consider these patches separately from the rest
of the PCID stuff -- they barely interact, and this part is much
simpler and is useful on its own.

Changes from v2:
 - Add macros for the INVPCID mode numbers.
 - Add a changelog message for the chicken bit.

v1 was exactly identical to patches 2-4 of the PCID RFC series.
Andy Lutomirski (3):
  x86/mm: Add INVPCID helpers
  x86/mm: Add a noinvpcid option to turn off INVPCID
  x86/mm: If INVPCID is available, use it to flush global mappings

 Documentation/kernel-parameters.txt |  2 ++
 arch/x86/include/asm/tlbflush.h     | 57 +++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c        | 16 +++++++++++
 3 files changed, 75 insertions(+)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
