Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCECD6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:59:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so289874456pgf.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:59:33 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id t8si17129623pgn.178.2017.01.25.15.59.31
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 15:59:32 -0800 (PST)
Date: Thu, 26 Jan 2017 00:59:24 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/2] setgid hardening
Message-ID: <20170125235924.GC23701@1wt.eu>
References: <cover.1485377903.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1485377903.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: security@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Wed, Jan 25, 2017 at 01:06:50PM -0800, Andy Lutomirski wrote:
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

BTW I like this. I vaguely remember having played with this when I
was a student 2 decades ago on a system where /var/spool/mail was
3777 (yes, setgid+sticky) and the mail files were 660. You could
deposit a shell there, then execute it with mail's permissions and
access any mailbox. That was quite odd as a design choice. The
impacts are often limited unless you find other ways to escalate
but generally it's not really clean.

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
