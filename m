Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A2A3A8D003C
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:28:07 -0400 (EDT)
Message-ID: <20110316022804.27679.qmail@science.horizon.com>
From: George Spelvin <linux@horizon.com>
Date: Sun, 13 Mar 2011 20:20:44 -0400
Subject: [PATCH 1/8] drivers/random: Cache align ip_random better
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@horizon.com

Cache aligning the secret[] buffer makes copying from it infinitesimally
more efficient.
---
 drivers/char/random.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 72a4fcb..4bcc4f2 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1417,8 +1417,8 @@ static __u32 twothirdsMD4Transform(__u32 const buf[4], __u32 const in[12])
 #define HASH_MASK ((1 << HASH_BITS) - 1)
 
 static struct keydata {
-	__u32 count; /* already shifted to the final position */
 	__u32 secret[12];
+	__u32 count; /* already shifted to the final position */
 } ____cacheline_aligned ip_keydata[2];
 
 static unsigned int ip_cnt;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
