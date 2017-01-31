Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9046B0266
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 22:56:26 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id j94so211887662uad.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:56:26 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id q9si4417291uaf.142.2017.01.30.19.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 19:56:25 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id i68so264375819uad.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:56:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHO5Pa21FTT9ZRiYbAQ43=Zd+qwP4KXgCbs+40iQ3cV_LPSR3Q@mail.gmail.com>
References: <cover.1485571668.git.luto@kernel.org> <CAHO5Pa21FTT9ZRiYbAQ43=Zd+qwP4KXgCbs+40iQ3cV_LPSR3Q@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 30 Jan 2017 19:56:04 -0800
Message-ID: <CALCETrUuR-ZkvEs0_5aN4yyyR34jYcJj7-_VjOv4nJWu6fvOjA@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] setgid hardening
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "security@kernel.org" <security@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, Linux API <linux-api@vger.kernel.org>

On Mon, Jan 30, 2017 at 7:49 PM, Michael Kerrisk <mtk.manpages@gmail.com> wrote:
> [CC += linux-api@]
>
> Andy, this is an API change!

Indeed.  I should be ashamed of myself!

>
> On Sat, Jan 28, 2017 at 3:49 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> The kernel has some dangerous behavior involving the creation and
>> modification of setgid executables.  These issues aren't kernel
>> security bugs per se, but they have been used to turn various
>> filesystem permission oddities into reliably privilege escalation
>> exploits.
>>
>> See http://www.halfdog.net/Security/2015/SetgidDirectoryPrivilegeEscalation/
>> for a nice writeup.
>>
>> Let's fix them for real.
>>
>> Changes from v1:
>>  - Fix uninitialized variable issue (Willy, Ben)
>>  - Also check current creds in should_remove_suid() (Ben)
>>
>> Andy Lutomirski (2):
>>   fs: Check f_cred as well as of current's creds in should_remove_suid()
>>   fs: Harden against open(..., O_CREAT, 02777) in a setgid directory
>>
>>  fs/inode.c         | 61 ++++++++++++++++++++++++++++++++++++++++++++++--------
>>  fs/internal.h      |  2 +-
>>  fs/ocfs2/file.c    |  4 ++--
>>  fs/open.c          |  2 +-
>>  include/linux/fs.h |  2 +-
>>  5 files changed, 57 insertions(+), 14 deletions(-)
>>
>> --
>> 2.9.3
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>
>
> --
> Michael Kerrisk Linux man-pages maintainer;
> http://www.kernel.org/doc/man-pages/
> Author of "The Linux Programming Interface", http://blog.man7.org/



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
