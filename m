Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 023648E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 11:23:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so13089124edz.15
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:23:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23-v6sor4123022eju.43.2018.12.18.08.23.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 08:23:16 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] memory_hotplug: add missing newlines to debugging output
Date: Tue, 18 Dec 2018 17:23:07 +0100
Message-Id: <20181218162307.10518-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

pages_correctly_probed is missing new lines which means that the line is
not printed rightaway but it rather waits for additional printks.

Add \n to all three messages in pages_correctly_probed.

Fixes: b77eab7079d9 ("mm/memory_hotplug: optimize probe routine")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 0e5985682642..b5ff45ab7967 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -207,15 +207,15 @@ static bool pages_correctly_probed(unsigned long start_pfn)
 			return false;
 
 		if (!present_section_nr(section_nr)) {
-			pr_warn("section %ld pfn[%lx, %lx) not present",
+			pr_warn("section %ld pfn[%lx, %lx) not present\n",
 				section_nr, pfn, pfn + PAGES_PER_SECTION);
 			return false;
 		} else if (!valid_section_nr(section_nr)) {
-			pr_warn("section %ld pfn[%lx, %lx) no valid memmap",
+			pr_warn("section %ld pfn[%lx, %lx) no valid memmap\n",
 				section_nr, pfn, pfn + PAGES_PER_SECTION);
 			return false;
 		} else if (online_section_nr(section_nr)) {
-			pr_warn("section %ld pfn[%lx, %lx) is already online",
+			pr_warn("section %ld pfn[%lx, %lx) is already online\n",
 				section_nr, pfn, pfn + PAGES_PER_SECTION);
 			return false;
 		}
-- 
2.19.2
