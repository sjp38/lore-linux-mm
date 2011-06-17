Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7E56B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 16:43:41 -0400 (EDT)
Received: from cpec03f0ed08c7f-cm001ac318e826.cpe.net.cable.rogers.com ([99.241.2.77] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1QXftD-0002GL-8N
	for linux-mm@kvack.org; Fri, 17 Jun 2011 16:43:39 -0400
Date: Fri, 17 Jun 2011 16:43:34 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] TMPFS: Add "tmpfs" to the Kconfig prompt to make it
 obvious.
Message-ID: <alpine.DEB.2.02.1106171641470.15335@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Add the leading word "tmpfs" to the Kconfig string to make it
blindingly obvious that this selection refers to tmpfs.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

diff --git a/fs/Kconfig b/fs/Kconfig
index 19891aa..b406da6 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -109,7 +109,7 @@ source "fs/proc/Kconfig"
 source "fs/sysfs/Kconfig"

 config TMPFS
-	bool "Virtual memory file system support (former shm fs)"
+	bool "Tmpfs virtual memory file system support (former shm fs)"
 	depends on SHMEM
 	help
 	  Tmpfs is a file system which keeps all files in virtual memory.

-- 

========================================================================
Robert P. J. Day                                 Ottawa, Ontario, CANADA
                        http://crashcourse.ca

Twitter:                                       http://twitter.com/rpjday
LinkedIn:                               http://ca.linkedin.com/in/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
