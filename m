Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7A16B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:18:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id e3-v6so741126qkj.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:18:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z19-v6si1070734qvj.60.2018.07.17.06.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 06:18:49 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and movable_core=
Date: Tue, 17 Jul 2018 21:18:37 +0800
Message-Id: <20180717131837.18411-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org, Baoquan He <bhe@redhat.com>

We can still use 'kernelcore=mirror' or 'movable_node' for the usage
of hotplug and movable zone. If somebody shows up with a valid usecase
we can reconsider.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Baoquan He <bhe@redhat.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 2 ++
 mm/page_alloc.c                                 | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index efc7aa7a0670..1e22c49866a2 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1855,6 +1855,7 @@
 	keepinitrd	[HW,ARM]
 
 	kernelcore=	[KNL,X86,IA-64,PPC]
+			[Usage of kernelcore=nn[KMGTPE] | nn% is deprecated]
 			Format: nn[KMGTPE] | nn% | "mirror"
 			This parameter specifies the amount of memory usable by
 			the kernel for non-movable allocations.  The requested
@@ -2395,6 +2396,7 @@
 			reporting absolute coordinates, such as tablets
 
 	movablecore=	[KNL,X86,IA-64,PPC]
+			[Deprecated]
 			Format: nn[KMGTPE] | nn%
 			This parameter is the complement to kernelcore=, it
 			specifies the amount of memory used for migratable
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..86cf05f48b5f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6899,6 +6899,8 @@ static int __init cmdline_parse_kernelcore(char *p)
 		return 0;
 	}
 
+	pr_warn("Only kernelcore=mirror supported, "
+		"usage of kernelcore=nn[KMGTPE]|nn%% is deprecated.\n");
 	return cmdline_parse_core(p, &required_kernelcore,
 				  &required_kernelcore_percent);
 }
@@ -6909,6 +6911,7 @@ static int __init cmdline_parse_kernelcore(char *p)
  */
 static int __init cmdline_parse_movablecore(char *p)
 {
+	pr_warn("Option movablecore= is deprecated.\n");
 	return cmdline_parse_core(p, &required_movablecore,
 				  &required_movablecore_percent);
 }
-- 
2.13.6
