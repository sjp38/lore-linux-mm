Date: Fri, 9 Dec 2005 11:47:41 -0800
From: Rohit Seth <rohit.seth@intel.com>
Subject: [PATCH]: gets a new online cpu to use percpu_pagelist_fraction
Message-ID: <20051209114740.A557@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If percpu_pagelist_fraction tunable is set then this patch allows a newly
brought online cpu to use new settings for high and batch values in its 
per cpu pagelists.

Signed-off-by: Rohit Seth <rohit.seth@intel.com>


--- c/mm/page_alloc.c	2005-12-09 03:43:22.000000000 -0800
+++ linux-2.6.15-rc5-mm1/mm/page_alloc.c	2005-12-09 03:45:28.000000000 -0800
@@ -1977,6 +1977,10 @@
 			goto bad;
 
 		setup_pageset(zone->pageset[cpu], zone_batchsize(zone));
+
+		if (percpu_pagelist_fraction) 
+			setup_pagelist_highmark(zone_pcp(zone, cpu), 
+			 	(zone->present_pages / percpu_pagelist_fraction));
 	}
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
