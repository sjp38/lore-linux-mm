Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C02C86B0010
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 22:12:29 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p8F2CRZU026231
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 19:12:27 -0700
Received: from ywe9 (ywe9.prod.google.com [10.192.5.9])
	by hpaq1.eem.corp.google.com with ESMTP id p8F2CKVd016839
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 19:12:25 -0700
Received: by ywe9 with SMTP id 9so1919906ywe.28
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 19:12:20 -0700 (PDT)
Date: Wed, 14 Sep 2011 19:12:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] thp: fix khugepaged defrag tunable documentation
Message-ID: <alpine.DEB.2.00.1109141910560.12561@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org

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
