Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 5208D6B00EB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:54 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 07/18] Configuration menu for Huge Page Cache
Date: Thu, 16 Feb 2012 15:31:34 +0100
Message-Id: <1329402705-25454-7-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Just, adds config options for enabling huge page cache and
enabling it in shmfs (tmpfs).

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 init/Kconfig |    6 ++++++
 mm/Kconfig   |   11 +++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 3f42cd6..a58b622 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1135,6 +1135,12 @@ config SHMEM
 	  option replaces shmem and tmpfs with the much simpler ramfs code,
 	  which may be appropriate on small systems without swap.
 
+config SHMEM_HUGEPAGECACHE
+	bool "Allow usage of transparent huge pages"
+	depends on HUGEPAGECACHE && SHMEM
+	help
+	  This allows usage of huge pages in shmfs (tmpfs)
+
 config AIO
 	bool "Enable AIO support" if EXPERT
 	default y
diff --git a/mm/Kconfig b/mm/Kconfig
index e338407..494122d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -349,6 +349,17 @@ choice
 	  benefit.
 endchoice
 
+config HUGEPAGECACHE
+	bool "Support for huge pages in page cache"
+	depends on TRANSPARENT_HUGEPAGE
+	select COMPACTION 
+	help
+	  Huge pages in page cache allows to transaprently use huge
+	  pages in file maped regions. This options just exports
+	  required interfaces, You will need to enable support
+	  for Huge Page Cache for particullar filesystems.
+	  Currently only shmfs supports huge pages in page cache.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
