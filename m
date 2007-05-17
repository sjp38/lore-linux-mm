From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070517101022.3113.15456.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/5] Annotation fixes for grouping pages by mobility v2
Date: Thu, 17 May 2007 11:10:22 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog since V1
o Added Acks from Christoph Lameter

Hi Andrew,

The following patches deal with annotation fixups and clarifications on
GFP flag usage only. In particular, the last patch in this set fixes the
issue with grow_dev_page() using __GFP_RECLAIMABLE that was brought up
yesterday. Please merge.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
