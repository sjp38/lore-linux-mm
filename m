Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 455226B1CA1
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:26:15 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so610924pla.2
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:26:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor48146850pgp.79.2018.11.19.21.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 21:26:14 -0800 (PST)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH -manpage 2/2] memfd_create.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal
Date: Mon, 19 Nov 2018 21:25:45 -0800
Message-Id: <20181120052545.76560-2-joel@joelfernandes.org>
In-Reply-To: <20181120052545.76560-1-joel@joelfernandes.org>
References: <20181120052545.76560-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-man@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, John Stultz <john.stultz@linaro.org>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

More details of the seal can be found in the LKML patch:
https://lore.kernel.org/lkml/20181120052137.74317-1-joel@joelfernandes.org/T/#t

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 man2/memfd_create.2 | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/man2/memfd_create.2 b/man2/memfd_create.2
index 3cd392d1b4d9..fce2bf8d0fff 100644
--- a/man2/memfd_create.2
+++ b/man2/memfd_create.2
@@ -280,7 +280,15 @@ in order to restrict further modifications on the file.
 (If placing the seal
 .BR F_SEAL_WRITE ,
 then it will be necessary to first unmap the shared writable mapping
-created in the previous step.)
+created in the previous step. Otherwise, behavior similar to
+.BR F_SEAL_WRITE
+can be achieved, by using
+.BR F_SEAL_FUTURE_WRITE
+which will prevent future writes via
+.BR mmap (2)
+and
+.BR write (2)
+from succeeding, while keeping existing shared writable mappings).
 .IP 4.
 A second process obtains a file descriptor for the
 .BR tmpfs (5)
@@ -425,6 +433,7 @@ main(int argc, char *argv[])
         fprintf(stderr, "\\t\\tg \- F_SEAL_GROW\\n");
         fprintf(stderr, "\\t\\ts \- F_SEAL_SHRINK\\n");
         fprintf(stderr, "\\t\\tw \- F_SEAL_WRITE\\n");
+        fprintf(stderr, "\\t\\tW \- F_SEAL_FUTURE_WRITE\\n");
         fprintf(stderr, "\\t\\tS \- F_SEAL_SEAL\\n");
         exit(EXIT_FAILURE);
     }
@@ -463,6 +472,8 @@ main(int argc, char *argv[])
             seals |= F_SEAL_SHRINK;
         if (strchr(seals_arg, \(aqw\(aq) != NULL)
             seals |= F_SEAL_WRITE;
+        if (strchr(seals_arg, \(aqW\(aq) != NULL)
+            seals |= F_SEAL_FUTURE_WRITE;
         if (strchr(seals_arg, \(aqS\(aq) != NULL)
             seals |= F_SEAL_SEAL;
 
@@ -518,6 +529,8 @@ main(int argc, char *argv[])
         printf(" GROW");
     if (seals & F_SEAL_WRITE)
         printf(" WRITE");
+    if (seals & F_SEAL_FUTURE_WRITE)
+        printf(" FUTURE_WRITE");
     if (seals & F_SEAL_SHRINK)
         printf(" SHRINK");
     printf("\\n");
-- 
2.19.1.1215.g8438c0b245-goog
