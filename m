Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 621C46B0072
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 14:40:32 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so1164588pdb.5
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 11:40:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ca3si3240178pbb.168.2014.12.09.11.40.30
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 11:40:31 -0800 (PST)
Date: Wed, 10 Dec 2014 03:38:17 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH tj-misc] bitmap: bitmap_print_list() can be static
Message-ID: <20141209193817.GA27635@lkp-sb04>
References: <201412100354.d6xN5OCa%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412100354.d6xN5OCa%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Sudeep Holla <sudeep.holla@arm.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org

lib/bitmap.c:574:6: sparse: symbol 'bitmap_print_list' was not declared. Should it be static?

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 bitmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/bitmap.c b/lib/bitmap.c
index c5dd40e..dc43a01 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -571,7 +571,7 @@ static inline void bscnl_emit(int rbot, int rtop, bool first,
 		printfn(printfn_data, "%d-%d", rbot, rtop);
 }
 
-void bitmap_print_list(const unsigned long *maskp, int nmaskbits,
+static void bitmap_print_list(const unsigned long *maskp, int nmaskbits,
 		       bitmap_printfn_t printfn, void *printfn_data)
 {
 	bool first = true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
