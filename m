Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1C78A6B00A8
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 21:12:38 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id y13so4954723pdi.41
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:12:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id w7si21596897pbg.292.2013.11.12.18.12.35
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 18:12:36 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id y13so4961136pdi.14
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:12:34 -0800 (PST)
Date: Tue, 12 Nov 2013 18:12:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, mempolicy: silence gcc warning
Message-ID: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

Fengguang Wu reports that compiling mm/mempolicy.c results in a warning:

	mm/mempolicy.c: In function 'mpol_to_str':
	mm/mempolicy.c:2878:2: error: format not a string literal and no format arguments

Kees says this is because he is using -Wformat-security.

Silence the warning.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Suggested-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2950,7 +2950,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 		return;
 	}
 
-	p += snprintf(p, maxlen, policy_modes[mode]);
+	p += snprintf(p, maxlen, "%s", policy_modes[mode]);
 
 	if (flags & MPOL_MODE_FLAGS) {
 		p += snprintf(p, buffer + maxlen - p, "=");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
