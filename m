Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1E776B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:32:18 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id a194so214807072oib.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:32:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k11si7258001oih.160.2017.01.24.02.32.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 02:32:18 -0800 (PST)
Subject: Re: [Ksummit-discuss] security-related TODO items?
References: <CAGXu5j+nVMPk3TTxLr3_6Y=5vNM0=aD+13JM_Q5POts9M7kzuw@mail.gmail.com>
 <CALCETrVKDAzcS62wTjDOGuRUNec_a-=8iEa7QQ62V83Ce2nk=A@mail.gmail.com>
 <31033.1485168526@warthog.procyon.org.uk>
 <CALCETrV5b4Z3MF51pQOPtp-BgMM4TYPLrXPHL+EfsWfm+CczkA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <c1822e5b-9352-c1ab-ee98-e492ef6e156a@I-love.SAKURA.ne.jp>
Date: Tue, 24 Jan 2017 19:32:02 +0900
MIME-Version: 1.0
In-Reply-To: <CALCETrV5b4Z3MF51pQOPtp-BgMM4TYPLrXPHL+EfsWfm+CczkA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, David Howells <dhowells@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Kees Cook <keescook@chromium.org>, Josh Armour <jarmour@google.com>, Greg KH <gregkh@linuxfoundation.org>, "ksummit-discuss@lists.linuxfoundation.org" <ksummit-discuss@lists.linuxfoundation.org>

Hello.

Can I read archive of the discussion of this topic from the beginning?
I felt that this topic might be an opportunity of proposing my execute handler
approach.

In TOMOYO LSM (out of tree version), administrator can specify a program
called execute handler which should be executed on behalf of a program
requested by execve(). The specified program performs validation (e.g. whether
argv[]/envp[] are appropriate) and setup (e.g. redirect file handles) before
executing the program requested by execve().

Conceptually execute handler is something like

  #!/bin/sh
  test ... || exit 1
  test ... || exit 1
  test ... || exit 1
  exec ...

which would in practice be implemented using C like
https://osdn.net/projects/tomoyo/scm/svn/blobs/head/tags/ccs-tools/1.8.5p1/usr_lib_ccs/audit-exec-param.c .
It is not difficult to implement the kernel side as well.

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
