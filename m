Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94DF26B0266
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:00:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b22-v6so5849560pfc.18
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:00:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e7-v6si26111287pgn.82.2018.10.10.13.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 13:00:20 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 6/6] tools/gup_benchmark: Add MAP_HUGETLB option
Date: Wed, 10 Oct 2018 13:56:05 -0600
Message-Id: <20181010195605.10689-6-keith.busch@intel.com>
In-Reply-To: <20181010195605.10689-1-keith.busch@intel.com>
References: <20181010195605.10689-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Keith Busch <keith.busch@intel.com>

This patch adds a new option, '-H', to the gup benchmark to help compare how
hugetlb mapping pages compare with the default.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 tools/testing/selftests/vm/gup_benchmark.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index 24528b54549d..c7b5934c6d7f 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -36,7 +36,7 @@ int main(int argc, char **argv)
 	char *file = "/dev/zero";
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUS")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUSH")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -69,6 +69,9 @@ int main(int argc, char **argv)
 			flags &= ~MAP_PRIVATE;
 			flags |= MAP_SHARED;
 			break;
+		case 'H':
+			flags |= MAP_HUGETLB;
+			break;
 		default:
 			return -1;
 		}
-- 
2.14.4
