Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id EBE646B0276
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 16:39:08 -0400 (EDT)
Received: by iow1 with SMTP id 1so62220745iow.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:39:08 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id k2si3769442igg.13.2015.10.01.13.39.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 13:39:08 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so3653136igb.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:39:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151001111718.GA25333@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
	<20150916174913.AF5FEA6D@viggo.jf.intel.com>
	<20150920085554.GA21906@gmail.com>
	<55FF88BA.6080006@sr71.net>
	<20150924094956.GA30349@gmail.com>
	<56044A88.7030203@sr71.net>
	<20151001111718.GA25333@gmail.com>
Date: Thu, 1 Oct 2015 13:39:07 -0700
Message-ID: <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dave Hansen <dave@sr71.net> wrote:
>
>> > If yes then this could be a significant security feature / usecase for pkeys:

Which CPUs (will) have pkeys?

>> > executable sections of shared libraries and binaries could be mapped with pkey
>> > access disabled. If I read the Intel documentation correctly then that should
>> > be possible.
>>
>> Agreed.  I've even heard from some researchers who are interested in this:
>>
>> https://www.infsec.cs.uni-saarland.de/wp-content/uploads/sites/2/2014/10/nuernberger2014ccs_disclosure.pdf
>
> So could we try to add an (opt-in) kernel option that enables this transparently
> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
> user-space changes and syscalls necessary?

I would like this very much. :)

> Beyond the security improvement, this would enable this hardware feature on most
> x86 Linux distros automatically, on supported hardware, which is good for testing.
>
> Assuming it boots up fine on a typical distro, i.e. assuming that there are no
> surprises where PROT_READ && PROT_EXEC sections are accessed as data.

I can't wait to find out what implicitly expects PROT_READ from
PROT_EXEC mappings. :)

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
