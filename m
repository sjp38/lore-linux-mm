Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id CD77A4402F8
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 14:08:30 -0400 (EDT)
Received: by iofh134 with SMTP id h134so128970735iof.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 11:08:30 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id q93si9645748ioi.48.2015.10.02.11.08.29
        for <linux-mm@kvack.org>;
        Fri, 02 Oct 2015 11:08:29 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
 <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
 <560DBA24.5010201@sr71.net>
 <CA+55aFxf3ExQEq2zhNhj4zk5nC5in9=1acVfynOVxZdN9RLbdA@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560EC81B.60809@sr71.net>
Date: Fri, 2 Oct 2015 11:08:27 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFxf3ExQEq2zhNhj4zk5nC5in9=1acVfynOVxZdN9RLbdA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/01/2015 06:38 PM, Linus Torvalds wrote:
> On Thu, Oct 1, 2015 at 6:56 PM, Dave Hansen <dave@sr71.net> wrote:
>>
>> Also, a quick ftrace showed that most mmap() callers that set PROT_EXEC
>> also set PROT_READ.  I'm just assuming that folks are setting PROT_READ
>> but aren't _really_ going to read it, so we can safely deny them all
>> access other than exec.
> 
> That's a completely insane assumption. There are tons of reasons to
> have code and read-only data in the same segment, and it's very
> traditional. Just assuming that you only execute out of something that
> has PROT_EXEC | PROT_READ is insane.

Yes, it's insane, and I confirmed that ld.so actually reads some stuff
out of the first page of the r-x part of the executable.

But, it did find a bug in my code where I wouldn't allow instruction
fetches to fault in pages in a pkey-protected area, so it wasn't a
completely worthless exercise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
