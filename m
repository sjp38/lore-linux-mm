Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0FAC6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:53:39 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id 23so94837871vkc.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:53:39 -0800 (PST)
Received: from mail-vk0-x235.google.com (mail-vk0-x235.google.com. [2607:f8b0:400c:c05::235])
        by mx.google.com with ESMTPS id c59si4605888uac.17.2017.01.23.13.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 13:53:39 -0800 (PST)
Received: by mail-vk0-x235.google.com with SMTP id x75so100135251vke.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:53:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFhKne8+cuH6vsu1JqRt5i=yMGH1Qv_RLJf07vQhkxUU-ajS1Q@mail.gmail.com>
References: <CAGXu5j+nVMPk3TTxLr3_6Y=5vNM0=aD+13JM_Q5POts9M7kzuw@mail.gmail.com>
 <CALCETrVKDAzcS62wTjDOGuRUNec_a-=8iEa7QQ62V83Ce2nk=A@mail.gmail.com>
 <31033.1485168526@warthog.procyon.org.uk> <CALCETrV5b4Z3MF51pQOPtp-BgMM4TYPLrXPHL+EfsWfm+CczkA@mail.gmail.com>
 <5024.1485203788@warthog.procyon.org.uk> <CAFhKne8+cuH6vsu1JqRt5i=yMGH1Qv_RLJf07vQhkxUU-ajS1Q@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 23 Jan 2017 13:53:18 -0800
Message-ID: <CALCETrW9oP7=77X1tN2OQhtiamyR94yT_=00ZxgbuGvzHK--9A@mail.gmail.com>
Subject: Re: [Ksummit-discuss] security-related TODO items?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy6545@gmail.com>
Cc: David Howells <dhowells@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Josh Armour <jarmour@google.com>, "ksummit-discuss@lists.linuxfoundation.org" <ksummit-discuss@lists.linuxfoundation.org>

On Mon, Jan 23, 2017 at 12:59 PM, Matthew Wilcox <willy6545@gmail.com> wrote:
> Why put it in the user address space? As I said earlier in this thread, we
> want the facility to run code from kernel addresses in user mode, limited to
> only being able to access its own stack and the user addresses. Of course it
> should also be able to make syscalls, like mmap.

Would you believe I've already started prototyping this (the
kernel-code-in-user-mode part, not the execve part)?

As a practical matter, though, I think the implementation would be
*much* simpler if code running in user mode sees user addresses.
Otherwise we'd end up with very messy and constrained code on
single-address-space arches like x86 and we might not be able to
implement it at all on split-address-space arches like s390.

That being said, writing a bit of PIC code that parses the ELF file,
finds some unused address space, and relocates itself out of the way
shouldn't be *that* hard.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
