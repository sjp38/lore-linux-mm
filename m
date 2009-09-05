Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3BD2F6B0095
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 20:44:59 -0400 (EDT)
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <linux-mm@kvack.org>; Fri, 04 Sep 2009 17:45:03 -0700
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH v3 5/5] kmemleak: fix sparse warning for static declarations
Date: Fri, 4 Sep 2009 17:44:54 -0700
Message-ID: <1252111494-7593-6-git-send-email-lrodriguez@atheros.com>
In-Reply-To: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mcgrof@gmail.com, "Luis R. Rodriguez" <lrodriguez@atheros.com>
List-ID: <linux-mm.kvack.org>

This fixes these sparse warnings:

mm/kmemleak.c:1179:6: warning: symbol 'start_scan_thread' was not declared. Should it be static?
mm/kmemleak.c:1194:6: warning: symbol 'stop_scan_thread' was not declared. Should it be static?

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 mm/kmemleak.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index d078621..9b14e24 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1269,7 +1269,7 @@ static int kmemleak_scan_thread(void *arg)
  * Start the automatic memory scanning thread. This function must be called
  * with the scan_mutex held.
  */
-void start_scan_thread(void)
+static void start_scan_thread(void)
 {
 	if (scan_thread)
 		return;
@@ -1284,7 +1284,7 @@ void start_scan_thread(void)
  * Stop the automatic memory scanning thread. This function must be called
  * with the scan_mutex held.
  */
-void stop_scan_thread(void)
+static void stop_scan_thread(void)
 {
 	if (scan_thread) {
 		kthread_stop(scan_thread);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
