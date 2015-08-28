Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0A36B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:43:01 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so34539831qge.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:43:01 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id 3si8126663qhx.74.2015.08.28.11.42.59
        for <linux-mm@kvack.org>;
        Fri, 28 Aug 2015 11:42:59 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH] mremap.2: Add note about mremap with locked areas
Date: Fri, 28 Aug 2015 14:42:52 -0400
Message-Id: <1440787372-30214-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When mremap() is used to move or expand a mapping that is locked with
mlock() or equivalent it will attempt to populate the new area.
However, like mmap(MAP_LOCKED), mremap() will not fail if the area
cannot be populated.  Also like mmap(MAP_LOCKED) this might come as a
surprise to users and should be noted.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-man@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 man2/mremap.2 | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/man2/mremap.2 b/man2/mremap.2
index 071adb5..cf884e6 100644
--- a/man2/mremap.2
+++ b/man2/mremap.2
@@ -196,6 +196,17 @@ and the prototype for
 did not allow for the
 .I new_address
 argument.
+
+If
+.BR mremap ()
+is used to move or expand an area locked with
+.BR mlock (2)
+or equivalent, the
+.BR mremap ()
+call will make a best effort to populate the new area but will not fail
+with
+.B ENOMEM
+if the area cannot be populated.
 .SH SEE ALSO
 .BR brk (2),
 .BR getpagesize (2),
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
