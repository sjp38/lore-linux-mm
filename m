Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 222C46B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:17:19 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id py6so23035150pab.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:17:19 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30097.outbound.protection.outlook.com. [40.107.3.97])
        by mx.google.com with ESMTPS id c71si8152763pga.289.2016.10.27.07.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 07:17:18 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH 0/2] x86/vdso: small fixups for map_vdso
Date: Thu, 27 Oct 2016 17:15:14 +0300
Message-ID: <20161027141516.28447-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, 0x7f454c46@gmail.com, Cyrill
 Gorcunov <gorcunov@openvz.org>, Paul Bolle <pebolle@tiscali.nl>, Andy
 Lutomirski <luto@kernel.org>, oleg@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, x86@kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

The first one is a fixup for arch_prctl constants uapi visability,
the second is code simplification.

Dmitry Safonov (2):
  x86/prctl/uapi: remove ifdef for CHECKPOINT_RESTORE
  x86/vdso: set vdso pointer only after success

 arch/x86/entry/vdso/vma.c         | 10 +++-------
 arch/x86/include/uapi/asm/prctl.h |  8 +++-----
 2 files changed, 6 insertions(+), 12 deletions(-)

-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
