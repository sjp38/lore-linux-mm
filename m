Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E0C006B006A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:28:02 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 10/10] ksm: change ksm nice level to be 5
Date: Fri, 17 Jul 2009 20:30:50 +0300
Message-Id: <1247851850-4298-11-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-10-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com>
 <1247851850-4298-8-git-send-email-ieidus@redhat.com>
 <1247851850-4298-9-git-send-email-ieidus@redhat.com>
 <1247851850-4298-10-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com
List-ID: <linux-mm.kvack.org>

From: Izik Eidus <ieidus@redhat.com>

ksm should try not to disturb other tasks as much as possible.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 75d7802..4afe345 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1270,7 +1270,7 @@ static void ksm_do_scan(unsigned int scan_npages)
 
 static int ksm_scan_thread(void *nothing)
 {
-	set_user_nice(current, 0);
+	set_user_nice(current, 5);
 
 	while (!kthread_should_stop()) {
 		if (ksm_run & KSM_RUN_MERGE) {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
