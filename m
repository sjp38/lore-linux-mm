Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id C41586B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:33:01 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so76195645qge.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:33:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i195si25470529qhc.17.2015.07.28.07.33.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 07:33:01 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH 0/2] arm64: support initrd outside of mapped RAM
Date: Tue, 28 Jul 2015 10:32:39 -0400
Message-Id: <1438093961-15536-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>
Cc: "Arnd Bergmann <arnd@arndb.de>--cc=Ard Biesheuvel" <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mark Salter <msalter@redhat.com>

When booting an arm64 kernel w/initrd using UEFI/grub, use of mem= will likely
cut off part or all of the initrd. This leaves it outside the kernel linear
map which leads to failure when unpacking. The x86 code has a similar need to
relocate an initrd outside of mapped memory in some cases.

The current x86 code uses early_memremap() to copy the original initrd from
unmapped to mapped RAM. This patchset creates a generic copy_from_early_mem()
utility based on that x86 code and has arm64 use it to relocate the initrd
if necessary.

Mark Salter (2):
  mm: add utility for early copy from unmapped ram
  arm64: support initrd outside kernel linear map

 arch/arm64/kernel/setup.c           | 55 +++++++++++++++++++++++++++++++++++++
 include/asm-generic/early_ioremap.h |  6 ++++
 mm/early_ioremap.c                  | 22 +++++++++++++++
 3 files changed, 83 insertions(+)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
