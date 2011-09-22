Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E9FDA9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 17:11:44 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p8MLBg3e022279
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 14:11:42 -0700
Received: from gwj19 (gwj19.prod.google.com [10.200.10.19])
	by wpaz1.hot.corp.google.com with ESMTP id p8MLBMrs030079
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 14:11:41 -0700
Received: by gwj19 with SMTP id 19so1911570gwj.23
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 14:11:41 -0700 (PDT)
Date: Thu, 22 Sep 2011 14:11:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch resend] thp: fix khugepaged defrag tunable documentation
Message-ID: <alpine.DEB.2.00.1109221410300.1505@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

e27e6151b154 ("mm/thp: use conventional format for boolean attributes")
changed /sys/kernel/mm/transparent_hugepage/khugepaged/defrag to be tuned
by using 1 (enabled) or 0 (disabled) instead of "yes" and "no",
respectively.

Update the documentation.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/vm/transhuge.txt |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -123,10 +123,11 @@ be automatically shutdown if it's set to "never".
 khugepaged runs usually at low frequency so while one may not want to
 invoke defrag algorithms synchronously during the page faults, it
 should be worth invoking defrag at least in khugepaged. However it's
-also possible to disable defrag in khugepaged:
+also possible to disable defrag in khugepaged by writing 0 or enable
+defrag in khugepaged by writing 1:
 
-echo yes >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
-echo no >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
+echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
+echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
 
 You can also control how many pages khugepaged should scan at each
 pass:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
