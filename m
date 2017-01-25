Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA226B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:17:59 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id n21so270302379yba.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:17:59 -0800 (PST)
Received: from elasmtp-kukur.atl.sa.earthlink.net (elasmtp-kukur.atl.sa.earthlink.net. [209.86.89.65])
        by mx.google.com with ESMTPS id o1si6613266ywj.324.2017.01.25.15.17.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 15:17:58 -0800 (PST)
From: "Frank Filz" <ffilzlnx@mindspring.com>
References: <cover.1485377903.git.luto@kernel.org> <826ec4aab64ec304944098d15209f8c1ae65bb29.1485377903.git.luto@kernel.org>
In-Reply-To: <826ec4aab64ec304944098d15209f8c1ae65bb29.1485377903.git.luto@kernel.org>
Subject: RE: [PATCH 2/2] fs: Harden against open(..., O_CREAT, 02777) in a setgid directory
Date: Wed, 25 Jan 2017 15:17:16 -0800
Message-ID: <014401d27761$2c79f990$856decb0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andy Lutomirski' <luto@kernel.org>, security@kernel.org
Cc: 'Konstantin Khlebnikov' <koct9i@gmail.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, 'Kees Cook' <keescook@chromium.org>, 'Willy Tarreau' <w@1wt.eu>, linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'yalin wang' <yalin.wang2010@gmail.com>, 'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>, 'Jan Kara' <jack@suse.cz>, 'Linux FS Devel' <linux-fsdevel@vger.kernel.org>

> Currently, if you open("foo", O_WRONLY | O_CREAT | ..., 02777) in a
> directory that is setgid and owned by a different gid than current's
fsgid, you
> end up with an SGID executable that is owned by the directory's GID.  This
is
> a Bad Thing (tm).  Exploiting this is nontrivial because most ways of
creating a
> new file create an empty file and empty executables aren't particularly
> interesting, but this is nevertheless quite dangerous.
> 
> Harden against this type of attack by detecting this particular corner
case
> (unprivileged program creates SGID executable inode in SGID directory
> owned by a different GID) and clearing the new inode's SGID bit.

Nasty.

I'd love to see a test for this in xfstests and/or pjdfstests...

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
