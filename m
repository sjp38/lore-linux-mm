From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: avoid unnecessary iteration in get_pages_per_zspage()
Date: Thu,  5 May 2016 13:17:27 +0800
Message-ID: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>
List-Id: linux-mm.kvack.org

if we find a zspage with usage == 100%, there is no need to
try other zspages.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
---
 mm/zsmalloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index fda7177..310c7b0 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -765,6 +765,9 @@ static int get_pages_per_zspage(int class_size)
 		if (usedpc > max_usedpc) {
 			max_usedpc = usedpc;
 			max_usedpc_order = i;
+
+			if (max_usedpc == 100)
+				break;
 		}
 	}
 
-- 
1.7.9.5
