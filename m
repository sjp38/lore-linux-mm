Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E693A82F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:56:44 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so89307106pac.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:56:44 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id ba5si12007765pbb.193.2015.10.01.15.56.38
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 15:56:38 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
 <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560DBA24.5010201@sr71.net>
Date: Thu, 1 Oct 2015 15:56:36 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/01/2015 03:48 PM, Linus Torvalds wrote:
> On Thu, Oct 1, 2015 at 6:33 PM, Dave Hansen <dave@sr71.net> wrote:
>>
>> Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
>> if I boot with this, though.
>>
>> I'll see if I can turn it in to a bit more of an opt-in and see what's
>> actually going wrong.
...
> That said, I don't understand your patch. Why check PROT_WRITE? We've
> had :"execute but not write" forever. It's "execute and not *read*"
> that is interesting.

I was thinking that almost anybody doing a PROT_WRITE|PROT_EXEC really
*is* going to write to it so they'll notice pretty fast if we completely
deny them access to it.

Also, a quick ftrace showed that most mmap() callers that set PROT_EXEC
also set PROT_READ.  I'm just assuming that folks are setting PROT_READ
but aren't _really_ going to read it, so we can safely deny them all
access other than exec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
