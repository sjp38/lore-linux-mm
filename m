Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 491768E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 19:14:55 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id j125so13029447qke.12
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 16:14:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor80054998qtb.53.2019.01.12.16.14.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 16:14:54 -0800 (PST)
From: Joel Fernandes <joel@joelfernandes.org>
Subject: [PATCH -manpage 1/2] fcntl.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal
Date: Sat, 12 Jan 2019 19:14:45 -0500
Message-Id: <20190113001446.158789-2-joel@joelfernandes.org>
In-Reply-To: <20190113001446.158789-1-joel@joelfernandes.org>
References: <20190113001446.158789-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mtk.manpages@gmail.com
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, dancol@google.com, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, John Stultz <john.stultz@linaro.org>, linux-api@vger.kernel.org, linux-man@vger.kernel.org, linux-mm@kvack.org, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

From: "Joel Fernandes (Google)" <joel@joelfernandes.org>

More details of the seal can be found in the LKML patch:
https://lore.kernel.org/lkml/20181120052137.74317-1-joel@joelfernandes.org/T/#t

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 man2/fcntl.2 | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/man2/fcntl.2 b/man2/fcntl.2
index 03533d65b..54772f949 100644
--- a/man2/fcntl.2
+++ b/man2/fcntl.2
@@ -1525,6 +1525,21 @@ Furthermore, if there are any asynchronous I/O operations
 .RB ( io_submit (2))
 pending on the file,
 all outstanding writes will be discarded.
+.TP
+.BR F_SEAL_FUTURE_WRITE
+If this seal is set, the contents of the file can be modified only from
+existing writeable mappings that were created prior to the seal being set.
+Any attempt to create a new writeable mapping on the memfd via
+.BR mmap (2)
+will fail with
+.BR EPERM.
+Also any attempts to write to the memfd via
+.BR write (2)
+will fail with
+.BR EPERM.
+This is useful in situations where existing writable mapped regions need to be
+kept intact while preventing any future writes. For example, to share a
+read-only memory buffer to other processes that only the sender can write to.
 .\"
 .SS File read/write hints
 Write lifetime hints can be used to inform the kernel about the relative
-- 
2.20.1.97.g81188d93c3-goog
