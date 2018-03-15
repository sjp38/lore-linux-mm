Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05CE96B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:49:15 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 62-v6so3245615ply.4
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:49:14 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k7si3417660pgo.509.2018.03.15.06.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 06:49:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] x86/mm: Fix comment in detect_tme() regarding x86_phys_bits
Date: Thu, 15 Mar 2018 16:49:06 +0300
Message-Id: <20180315134907.9311-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180315134907.9311-1-kirill.shutemov@linux.intel.com>
References: <20180315134907.9311-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As Kai pointed, we adjust x86_phys_bits not only to communicate
available physical address space to virtual machines, but mainly to
reflect the fact that the address space is reduced.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Suggested-by: Kai Huang <kai.huang@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index f0481b85c39d..fd379358c58d 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -619,11 +619,8 @@ static void detect_tme(struct cpuinfo_x86 *c)
 #endif
 
 	/*
-	 * Exclude KeyID bits from physical address bits.
-	 *
-	 * We have to do this even if we are not going to use KeyID bits
-	 * ourself. VM guests still have to know that these bits are not usable
-	 * for physical address.
+	 * KeyID bits effectively lower number of physical address bits.
+	 * Let's update cpuinfo_x86::x86_phys_bits to reflect the fact.
 	 */
 	c->x86_phys_bits -= keyid_bits;
 }
-- 
2.16.1
