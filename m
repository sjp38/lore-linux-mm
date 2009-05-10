Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 00EF86B00A6
	for <linux-mm@kvack.org>; Sun, 10 May 2009 10:40:20 -0400 (EDT)
Subject: [PATCH] mm: exit.c reorder wait_opts to remove padding on 64 bit
 builds
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain
Date: Sun, 10 May 2009 15:40:55 +0100
Message-Id: <1241966455.2724.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

reorder struct wait_opts to remove 8 bytes of alignment padding on 64
bit builds

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
---

Hi Andrew,
Oleg asked me to send you this patch against your tree.

patch against latest mmotm.git.
successfully compiled but has had no other testing.

regards
Richard


diff --git a/kernel/exit.c b/kernel/exit.c
index 6e8c9fd..576e626 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1080,8 +1080,8 @@ SYSCALL_DEFINE1(exit_group, int, error_code)
 
 struct wait_opts {
 	enum pid_type		wo_type;
-	struct pid		*wo_pid;
 	int			wo_flags;
+	struct pid		*wo_pid;
 
 	struct siginfo __user	*wo_info;
 	int __user		*wo_stat;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
