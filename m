Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7145A6B0260
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:07:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 201so284732157pfw.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:07:04 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 30si2705811pla.317.2017.01.25.13.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 13:07:03 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 0/2] setgid hardening
Date: Wed, 25 Jan 2017 13:06:50 -0800
Message-Id: <cover.1485377903.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

The kernel has some dangerous behavior involving the creation and
modification of setgid executables.  These issues aren't kernel
security bugs per se, but they have been used to turn various
filesystem permission oddities into reliably privilege escalation
exploits.

See http://www.halfdog.net/Security/2015/SetgidDirectoryPrivilegeEscalation/
for a nice writeup.

Let's fix them for real.

Andy Lutomirski (2):
  fs: Check f_cred instead of current's creds in should_remove_suid()
  fs: Harden against open(..., O_CREAT, 02777) in a setgid directory

 fs/inode.c         | 37 ++++++++++++++++++++++++++++++-------
 fs/internal.h      |  2 +-
 fs/ocfs2/file.c    |  4 ++--
 fs/open.c          |  2 +-
 include/linux/fs.h |  2 +-
 5 files changed, 35 insertions(+), 12 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
