Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD4296B0033
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 22:49:59 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id z68so7261908qkc.5
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:49:59 -0800 (PST)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id d12si11042962qtg.321.2017.01.30.19.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 19:49:58 -0800 (PST)
Received: by mail-qk0-x242.google.com with SMTP id 11so21939022qkl.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:49:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1485571668.git.luto@kernel.org>
References: <cover.1485571668.git.luto@kernel.org>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Tue, 31 Jan 2017 16:49:37 +1300
Message-ID: <CAHO5Pa21FTT9ZRiYbAQ43=Zd+qwP4KXgCbs+40iQ3cV_LPSR3Q@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] setgid hardening
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: security@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, Linux API <linux-api@vger.kernel.org>

[CC += linux-api@]

Andy, this is an API change!

On Sat, Jan 28, 2017 at 3:49 PM, Andy Lutomirski <luto@kernel.org> wrote:
> The kernel has some dangerous behavior involving the creation and
> modification of setgid executables.  These issues aren't kernel
> security bugs per se, but they have been used to turn various
> filesystem permission oddities into reliably privilege escalation
> exploits.
>
> See http://www.halfdog.net/Security/2015/SetgidDirectoryPrivilegeEscalation/
> for a nice writeup.
>
> Let's fix them for real.
>
> Changes from v1:
>  - Fix uninitialized variable issue (Willy, Ben)
>  - Also check current creds in should_remove_suid() (Ben)
>
> Andy Lutomirski (2):
>   fs: Check f_cred as well as of current's creds in should_remove_suid()
>   fs: Harden against open(..., O_CREAT, 02777) in a setgid directory
>
>  fs/inode.c         | 61 ++++++++++++++++++++++++++++++++++++++++++++++--------
>  fs/internal.h      |  2 +-
>  fs/ocfs2/file.c    |  4 ++--
>  fs/open.c          |  2 +-
>  include/linux/fs.h |  2 +-
>  5 files changed, 57 insertions(+), 14 deletions(-)
>
> --
> 2.9.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
