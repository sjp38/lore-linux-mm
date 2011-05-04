Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A7A156B0022
	for <linux-mm@kvack.org>; Wed,  4 May 2011 03:32:50 -0400 (EDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] coredump: use task comm instead of (unknown)
Date: Wed,  4 May 2011 09:32:34 +0200
Message-Id: <1304494354-21487-1-git-send-email-jslaby@suse.cz>
In-Reply-To: <4DC0FFAB.1000805@gmail.com>
References: <4DC0FFAB.1000805@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>

If we don't know the file corresponding to the binary (i.e. exe_file
is unknown), use "task->comm (path unknown)" instead of simple
"(unknown)" as suggested by ak.

The fallback is the same as %e except it will append "(path unknown)".

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>
---
 fs/exec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 5ee7562..0a4d281 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1555,7 +1555,7 @@ static int cn_print_exe_file(struct core_name *cn)
 
 	exe_file = get_mm_exe_file(current->mm);
 	if (!exe_file)
-		return cn_printf(cn, "(unknown)");
+		return cn_printf(cn, "%s (path unknown)", current->comm);
 
 	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
 	if (!pathbuf) {
-- 
1.7.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
