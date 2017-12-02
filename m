Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8E926B0033
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 21:16:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q3so7509478pgv.16
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 18:16:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y73sor2203240pff.7.2017.12.01.18.16.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 18:16:34 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH] mmap.2: MAP_FIXED is no longer discouraged
Date: Fri,  1 Dec 2017 18:16:26 -0800
Message-Id: <20171202021626.26478-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

MAP_FIXED has been widely used for a very long time, yet the man
page still claims that "the use of this option is discouraged".

The documentation assumes that "less portable" == "must be discouraged".

Instead of discouraging something that is so useful and widely used,
change the documentation to explain its limitations better.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
While reviewing Michal Hocko's man page update for MAP_FIXED_SAFE,
I noticed that MAP_FIXED was no longer reflecting the current
situation, so here is a patch to bring it into the year 2017.

 man2/mmap.2 | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 385f3bfd5..a5a8eb47a 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -222,8 +222,10 @@ part of the existing mapping(s) will be discarded.
 If the specified address cannot be used,
 .BR mmap ()
 will fail.
-Because requiring a fixed address for a mapping is less portable,
-the use of this option is discouraged.
+Software that aspires to be portable should use this option with care, keeping
+in mind that the exact layout of a process' memory map is allowed to change
+significantly between kernel versions, C library versions, and operating system
+releases.
 .TP
 .B MAP_GROWSDOWN
 This flag is used for stacks.
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
