Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0DE98E0004
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so3376627pfi.10
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l62-v6si19232530pgd.30.2018.09.19.14.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:03 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 3/7] tools/gup_benchmark: Fix 'write' flag usage
Date: Wed, 19 Sep 2018 15:02:46 -0600
Message-Id: <20180919210250.28858-4-keith.busch@intel.com>
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
References: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

If the '-w' parameter was provided, the benchmark would exit due to a
mssing 'break'.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 tools/testing/selftests/vm/gup_benchmark.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index c2f785ded9b9..b2082df8beb4 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -60,6 +60,7 @@ int main(int argc, char **argv)
 			break;
 		case 'w':
 			write = 1;
+			break;
 		default:
 			return -1;
 		}
-- 
2.14.4
