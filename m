Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8F76B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:49:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o61-v6so3247097pld.5
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:49:15 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k7si3417660pgo.509.2018.03.15.06.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 06:49:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] x86/mm: Fix couple MKTME-related issues
Date: Thu, 15 Mar 2018 16:49:05 +0300
Message-Id: <20180315134907.9311-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Kai has pointed to few issues around x86_phys_bits in MKTME changes.

Here is fixes. Please review and consider applying.

Kirill A. Shutemov (2):
  x86/mm: Fix comment in detect_tme() regarding x86_phys_bits
  x86/mm: Do not lose cpuinfo_x86:x86_phys_bits adjustment

 arch/x86/include/asm/processor.h |  1 +
 arch/x86/kernel/cpu/amd.c        |  3 ++-
 arch/x86/kernel/cpu/common.c     | 14 ++++++++++++++
 arch/x86/kernel/cpu/intel.c      |  8 +++-----
 4 files changed, 20 insertions(+), 6 deletions(-)

-- 
2.16.1
