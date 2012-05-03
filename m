Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D9C9F6B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:33:58 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2755293pbb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 01:33:58 -0700 (PDT)
Date: Thu, 3 May 2012 16:34:39 +0800
From: "majianpeng" <majianpeng@gmail.com>
Subject: [PATCH] Documentations: Fix slabinfo.c directory in vm/slub.txt
Message-ID: <201205031634316254497@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

Because the place of slabinfo.c changed.So update in slub.txt.

Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 Documentation/vm/slub.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index 6752870..b0c6d1b 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -17,7 +17,7 @@ data and perform operation on the slabs. By default slabinfo only lists
 slabs that have data in them. See "slabinfo -h" for more options when
 running the command. slabinfo can be compiled with
 
-gcc -o slabinfo tools/slub/slabinfo.c
+gcc -o slabinfo tools/vm/slabinfo.c
 
 Some of the modes of operation of slabinfo require that slub debugging
 be enabled on the command line. F.e. no tracking information will be
-- 
1.7.5.4
 				
--------------
majianpeng
2012-05-03

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
