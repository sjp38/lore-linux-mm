Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id A0BF782F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:48:48 -0400 (EDT)
Received: by igxx6 with SMTP id x6so5488995igx.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:48:48 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id i34si6546951ioo.198.2015.10.01.15.48.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 15:48:47 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so5743139igb.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:48:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560DB4A6.6050107@sr71.net>
References: <20150916174903.E112E464@viggo.jf.intel.com>
	<20150916174913.AF5FEA6D@viggo.jf.intel.com>
	<20150920085554.GA21906@gmail.com>
	<55FF88BA.6080006@sr71.net>
	<20150924094956.GA30349@gmail.com>
	<56044A88.7030203@sr71.net>
	<20151001111718.GA25333@gmail.com>
	<CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
	<560DB4A6.6050107@sr71.net>
Date: Thu, 1 Oct 2015 18:48:47 -0400
Message-ID: <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Thu, Oct 1, 2015 at 6:33 PM, Dave Hansen <dave@sr71.net> wrote:
>
> Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
> if I boot with this, though.
>
> I'll see if I can turn it in to a bit more of an opt-in and see what's
> actually going wrong.

It's quite likely that you will find that compilers put read-only
constants in the text section, knowing that executable means readable.

So it's entirely possible that it's pretty much all over.

That said, I don't understand your patch. Why check PROT_WRITE? We've
had :"execute but not write" forever. It's "execute and not *read*"
that is interesting.

So I wonder if your testing is just bogus. But maybe I'm mis-reading this?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
