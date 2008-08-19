Received: by ti-out-0910.google.com with SMTP id j3so27673tid.8
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 10:47:12 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH 5/5] kmemtrace: Fix 2 typos in documentation.
Date: Tue, 19 Aug 2008 20:43:27 +0300
Message-Id: <1219167807-5407-5-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-4-git-send-email-eduard.munteanu@linux360.ro>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
 <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
 <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro>
 <1219167807-5407-4-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Corrected the ABI description and the kmemtrace usage guide. Thanks to
Randy Dunlap for noticing these errors.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 Documentation/ABI/testing/debugfs-kmemtrace |    2 +-
 Documentation/vm/kmemtrace.txt              |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/debugfs-kmemtrace b/Documentation/ABI/testing/debugfs-kmemtrace
index a5ff9a6..5e6a92a 100644
--- a/Documentation/ABI/testing/debugfs-kmemtrace
+++ b/Documentation/ABI/testing/debugfs-kmemtrace
@@ -63,7 +63,7 @@ Adding new data to the packet (features) is done at the end of the mandatory
 data:
 	Feature size	(2 byte)
 	Feature ID	(1 byte)
-	Feature data	(Feature size - 4 bytes)
+	Feature data	(Feature size - 3 bytes)
 
 
 Users:
diff --git a/Documentation/vm/kmemtrace.txt b/Documentation/vm/kmemtrace.txt
index 75360b1..f656cac 100644
--- a/Documentation/vm/kmemtrace.txt
+++ b/Documentation/vm/kmemtrace.txt
@@ -61,7 +61,7 @@ III. Quick usage guide
 ======================
 
 1) Get a kernel that supports kmemtrace and build it accordingly (i.e. enable
-CONFIG_KMEMTRACE and CONFIG_DEFAULT_ENABLED).
+CONFIG_KMEMTRACE and CONFIG_KMEMTRACE_DEFAULT_ENABLED).
 
 2) Get the userspace tool and build it:
 $ git-clone git://repo.or.cz/kmemtrace-user.git		# current repository
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
