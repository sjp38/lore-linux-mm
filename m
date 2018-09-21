Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 220FE8E0026
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:09 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a23-v6so7057059pfo.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:09 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w64-v6si8510159pgb.476.2018.09.21.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:07 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 5/6] tools/gup_benchmark: Add parameter for hugetlb
Date: Fri, 21 Sep 2018 16:39:55 -0600
Message-Id: <20180921223956.3485-6-keith.busch@intel.com>
In-Reply-To: <20180921223956.3485-1-keith.busch@intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
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
