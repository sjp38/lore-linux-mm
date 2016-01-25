Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CA7756B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:37:47 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id q63so88248074pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:37:47 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id xu3si22168401pab.94.2016.01.25.10.37.47
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 10:37:47 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 0/3] x86/mm: INVPCID support
Date: Mon, 25 Jan 2016 10:37:41 -0800
Message-Id: <cover.1453746505.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>

Ingo, before applying this, please apply these two KASAN fixes:

http://lkml.kernel.org/g/1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com
http://lkml.kernel.org/g/1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com

Without those fixes, this series will trigger a KASAN bug.

This is a straightforward speedup on Ivy Bridge and newer, IIRC.
(I tested on Skylake.  INVPCID is not available on Sandy Bridge.
I don't have Ivy Bridge, Haswell or Broadwell to test on, so I
could be wrong as to when the feature was introduced.)

I think we should consider these patches separately from the rest
of the PCID stuff -- they barely interact, and this part is much
simpler and is useful on its own.

This is exactly identical to patches 2-4 of the PCID RFC series.

Andy Lutomirski (3):
  x86/mm: Add INVPCID helpers
  x86/mm: Add a noinvpcid option to turn off INVPCID
  x86/mm: If INVPCID is available, use it to flush global mappings

 Documentation/kernel-parameters.txt |  2 ++
 arch/x86/include/asm/tlbflush.h     | 50 +++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c        | 16 ++++++++++++
 3 files changed, 68 insertions(+)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
