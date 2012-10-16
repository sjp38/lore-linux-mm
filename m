Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 23E4F6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 07:48:25 -0400 (EDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCHv3 1/6] lib/string: introduce helper to get base file name from given path
Date: Tue, 16 Oct 2012 14:48:08 +0300
Message-Id: <1350388094-18805-2-git-send-email-andriy.shevchenko@linux.intel.com>
In-Reply-To: <1350388094-18805-1-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1350388094-18805-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Jason Baron <jbaron@redhat.com>, YAMANE Toshiaki <yamanetoshi@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>

There are several places in the kernel that use functionality like basename(3)
with an exception: in case of '/foo/bar/' we expect to get an empty string.
Let's do it common helper for them.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Jason Baron <jbaron@redhat.com>
Cc: YAMANE Toshiaki <yamanetoshi@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
---
 include/linux/string.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 6301258..ac889c5 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -143,4 +143,15 @@ static inline bool strstarts(const char *str, const char *prefix)
 
 extern size_t memweight(const void *ptr, size_t bytes);
 
+/**
+ * kbasename - return the last part of a pathname.
+ *
+ * @path: path to extract the filename from.
+ */
+static inline const char *kbasename(const char *path)
+{
+	const char *tail = strrchr(path, '/');
+	return tail ? tail + 1 : path;
+}
+
 #endif /* _LINUX_STRING_H_ */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
