Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9996B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 12:56:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so113514864pfd.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:56:04 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i8si1360864pll.65.2017.02.06.09.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 09:56:03 -0800 (PST)
Subject: [PATCH] mm,x86: native_pud_clear missing on i386 build
From: Dave Jiang <dave.jiang@intel.com>
Date: Mon, 06 Feb 2017 10:55:52 -0700
Message-ID: <148640375195.69754.3315433724330910314.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mawilcox@microsoft.com, linux-nvdimm@lists.01.org, dave.hansen@linux.intel.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz

Missing dummy function native_pud_clear() for 32bit x86 build caught
by 0-day build.

Fix: a10a1701 mm, x86: add support for PUD-sized transparent hugepages

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 arch/x86/include/asm/pgtable-3level.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index be759ff..50d35e3 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -121,6 +121,10 @@ static inline void native_pmd_clear(pmd_t *pmd)
 	*(tmp + 1) = 0;
 }
 
+static inline void native_pud_clear(pud_t *pudp)
+{
+}
+
 static inline void pud_clear(pud_t *pudp)
 {
 	set_pud(pudp, __pud(0));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
