Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8BDF8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b29-v6so7154576pfm.1
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u18-v6si28263356pfa.28.2018.09.21.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:07 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 3/6] tools/gup_benchmark: Fix 'write' flag usage
Date: Fri, 21 Sep 2018 16:39:53 -0600
Message-Id: <20180921223956.3485-4-keith.busch@intel.com>
In-Reply-To: <20180921223956.3485-1-keith.busch@intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
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
