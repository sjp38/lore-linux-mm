Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 2AE396B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 09:21:51 -0400 (EDT)
From: Gergely Risko <gergely@risko.hu>
Subject: [PATCH] mm: memcontrol: fix handling of swapaccount parameter
Date: Wed, 14 Aug 2013 15:21:35 +0200
Message-Id: <1376486495-21457-1-git-send-email-gergely@risko.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, Gergely Risko <gergely@risko.hu>

Fixed swap accounting option parsing to enable if called without argument.

Signed-off-by: Gergely Risko <gergely@risko.hu>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c290a1c..8ec2507 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6970,13 +6970,13 @@ struct cgroup_subsys mem_cgroup_subsys = {
 static int __init enable_swap_account(char *s)
 {
 	/* consider enabled if no parameter or 1 is given */
-	if (!strcmp(s, "1"))
+	if (*s++ != '=' || !*s || !strcmp(s, "1"))
 		really_do_swap_account = 1;
 	else if (!strcmp(s, "0"))
 		really_do_swap_account = 0;
 	return 1;
 }
-__setup("swapaccount=", enable_swap_account);
+__setup("swapaccount", enable_swap_account);
 
 static void __init memsw_file_init(void)
 {
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
