Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFE26B0299
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:11:46 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f16so3518479qth.20
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 01:11:46 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u76si1029657qkl.209.2018.02.22.01.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 01:11:45 -0800 (PST)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 1/3] mm/sparse: Add a static variable nr_present_sections
Date: Thu, 22 Feb 2018 17:11:28 +0800
Message-Id: <20180222091130.32165-2-bhe@redhat.com>
In-Reply-To: <20180222091130.32165-1-bhe@redhat.com>
References: <20180222091130.32165-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, dave.hansen@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, Baoquan He <bhe@redhat.com>

It's used to record how many memory sections are marked as present
during system boot up, and will be used in the later patch.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 7af5e7a92528..433d3c9b4b56 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -202,6 +202,7 @@ static inline int next_present_section_nr(int section_nr)
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
+static int nr_present_sections;
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
@@ -231,6 +232,7 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 			ms->section_mem_map = sparse_encode_early_nid(nid) |
 							SECTION_IS_ONLINE;
 			section_mark_present(ms);
+			nr_present_sections++;
 		}
 	}
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
