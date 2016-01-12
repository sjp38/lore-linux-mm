Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8C17C680F85
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:45:21 -0500 (EST)
Received: by mail-qk0-f182.google.com with SMTP id n135so233664361qka.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:45:21 -0800 (PST)
Date: Mon, 11 Jan 2016 20:45:09 -0500
From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH 09/13] aio: add support for async openat()
Message-ID: <20160112014509.z6xefgc2rrkytmvk@ret.masoncoding.com>
References: <cover.1452549431.git.bcrl@kvack.org>
 <150a0b4905f1d7274b4c2c7f5e3f4d8df5dda1d7.1452549431.git.bcrl@kvack.org>
 <CA+55aFw8j_3Vkb=HVoMwWTPD=5ve8RpNZeL31CcKQZ+HRSbfTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CA+55aFw8j_3Vkb=HVoMwWTPD=5ve8RpNZeL31CcKQZ+HRSbfTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Ingo Molnar <mingo@kernel.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 04:22:28PM -0800, Linus Torvalds wrote:
> On Mon, Jan 11, 2016 at 2:07 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> > Another blocking operation used by applications that want aio
> > functionality is that of opening files that are not resident in memory.
> > Using the thread based aio helper, add support for IOCB_CMD_OPENAT.
> 
> So I think this is ridiculously ugly.
> 
> AIO is a horrible ad-hoc design, with the main excuse being "other,
> less gifted people, made that design, and we are implementing it for
> compatibility because database people - who seldom have any shred of
> taste - actually use it".
> 
> But AIO was always really really ugly.
> 
> Now you introduce the notion of doing almost arbitrary system calls
> asynchronously in threads, but then you use that ass-backwards nasty
> interface to do so.

[ ... ]

> I'm adding Ingo the to cc, because I think Ingo had a "run this list
> of system calls" patch at one point - in order to avoid system call
> overhead. I don't think that was very interesting (because system call
> overhead is seldom all that noticeable for any interesting system
> calls), but with the "let's do the list asynchronously" addition it
> might be much more intriguing. Ingo, do I remember correctly that it
> was you? I might be confused about who wrote that patch, and I can't
> find it now.

Zach Brown and Ingo traded a bunch of ideas.  There were chicklets and
syslets?  A little search, it looks like acall was a slightly different
iteration, but the patches didn't make it off oss.oracle.com:

https://lwn.net/Articles/316806/

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
