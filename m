Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE4F48E0004
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n17-v6so3344861pff.17
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:08 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l62-v6si19232530pgd.30.2018.09.19.14.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:03 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 5/7] tools/gup_benchmark: Add parameter for hugetlb
Date: Wed, 19 Sep 2018 15:02:48 -0600
Message-Id: <20180919210250.28858-6-keith.busch@intel.com>
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
References: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 tools/testing/selftests/vm/gup_benchmark.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index f2c99e2436f8..5d96e2b3d2f1 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -38,7 +38,7 @@ int main(int argc, char **argv)
 	char *file = NULL;
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:f:tTLU")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUH")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -64,6 +64,9 @@ int main(int argc, char **argv)
 		case 'w':
 			write = 1;
 			break;
+		case 'H':
+			flags |= MAP_HUGETLB;
+			break;
 		case 'f':
 			file = optarg;
 			flags &= ~(MAP_PRIVATE | MAP_ANONYMOUS);
-- 
2.14.4
