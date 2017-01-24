Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEBC66B026E
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:58:22 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id x75so110290088vke.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:58:22 -0800 (PST)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id h143si2845795vkd.216.2017.01.24.12.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 12:58:21 -0800 (PST)
Received: by mail-vk0-x236.google.com with SMTP id k127so120691061vke.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:58:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <c1822e5b-9352-c1ab-ee98-e492ef6e156a@I-love.SAKURA.ne.jp>
References: <CAGXu5j+nVMPk3TTxLr3_6Y=5vNM0=aD+13JM_Q5POts9M7kzuw@mail.gmail.com>
 <CALCETrVKDAzcS62wTjDOGuRUNec_a-=8iEa7QQ62V83Ce2nk=A@mail.gmail.com>
 <31033.1485168526@warthog.procyon.org.uk> <CALCETrV5b4Z3MF51pQOPtp-BgMM4TYPLrXPHL+EfsWfm+CczkA@mail.gmail.com>
 <c1822e5b-9352-c1ab-ee98-e492ef6e156a@I-love.SAKURA.ne.jp>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 24 Jan 2017 12:58:00 -0800
Message-ID: <CALCETrWj8_D_YL4PKZGbxx4HSZHyoctdvfriUVhE=x+NpQYLtw@mail.gmail.com>
Subject: Re: [Ksummit-discuss] security-related TODO items?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Howells <dhowells@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kees Cook <keescook@chromium.org>, Josh Armour <jarmour@google.com>, Greg KH <gregkh@linuxfoundation.org>, "ksummit-discuss@lists.linuxfoundation.org" <ksummit-discuss@lists.linuxfoundation.org>

On Tue, Jan 24, 2017 at 2:32 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Hello.
>
> Can I read archive of the discussion of this topic from the beginning?
> I felt that this topic might be an opportunity of proposing my execute handler
> approach.

It should be in the linux-mm archives.

>
> In TOMOYO LSM (out of tree version), administrator can specify a program
> called execute handler which should be executed on behalf of a program
> requested by execve(). The specified program performs validation (e.g. whether
> argv[]/envp[] are appropriate) and setup (e.g. redirect file handles) before
> executing the program requested by execve().
>
> Conceptually execute handler is something like
>
>   #!/bin/sh
>   test ... || exit 1
>   test ... || exit 1
>   test ... || exit 1
>   exec ...
>
> which would in practice be implemented using C like
> https://osdn.net/projects/tomoyo/scm/svn/blobs/head/tags/ccs-tools/1.8.5p1/usr_lib_ccs/audit-exec-param.c .
> It is not difficult to implement the kernel side as well.
>

The difference is that that last exec means that the kernel is still
exposed to any bugs in its ELF parser.  Moving that to user mode would
reduce the attack surface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
