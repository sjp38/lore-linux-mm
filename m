Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B32FD90010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:04:26 -0400 (EDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH v2 4/4] coredump: escape / in hostname and comm fix
Date: Thu, 12 May 2011 23:04:18 +0200
Message-Id: <1305234258-28184-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>

Escape comm also in failing %E case.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>
---
 fs/exec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index dafded4..13b4fce 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1563,8 +1563,8 @@ static int cn_print_exe_file(struct core_name *cn)
 	exe_file = get_mm_exe_file(current->mm);
 	if (!exe_file) {
 		char comm[TASK_COMM_LEN];
-		return cn_printf(cn, "%s (path unknown)", get_task_comm(comm,
-					current));
+		cn_escape(get_task_comm(comm, current));
+		return cn_printf(cn, "%s (path unknown)", comm);
 	}
 
 	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
-- 
1.7.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
