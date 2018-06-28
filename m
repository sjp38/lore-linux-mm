Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D26E6B0010
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:29:11 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v14-v6so4490597qto.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:29:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n32-v6si193457qta.356.2018.06.27.23.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 23:29:10 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v6 1/5] mm/sparse: Add a static variable nr_present_sections
Date: Thu, 28 Jun 2018 14:28:53 +0800
Message-Id: <20180628062857.29658-2-bhe@redhat.com>
In-Reply-To: <20180628062857.29658-1-bhe@redhat.com>
References: <20180628062857.29658-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

It's used to record how many memory sections are marked as present
during system boot up, and will be used in the later patch.

Signed-off-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index f13f2723950a..6314303130b0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -200,6 +200,12 @@ static inline int next_present_section_nr(int section_nr)
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
+/*
+ * Record how many memory sections are marked as present
+ * during system bootup.
+ */
+static int __initdata nr_present_sections;
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
@@ -229,6 +235,7 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 			ms->section_mem_map = sparse_encode_early_nid(nid) |
 							SECTION_IS_ONLINE;
 			section_mark_present(ms);
+			nr_present_sections++;
 		}
 	}
 }
-- 
2.13.6
