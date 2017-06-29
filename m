Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3886B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 15:28:13 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 99so34140450uar.11
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 12:28:13 -0700 (PDT)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id s194si2326254vkb.105.2017.06.29.12.28.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 12:28:12 -0700 (PDT)
Received: by mail-ua0-x22f.google.com with SMTP id j53so63255387uaa.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 12:28:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJTEoeGs8uBdHYdBJwacOp2b22ySrn-V8T93qaD4cv65A@mail.gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
 <1497544976-7856-4-git-send-email-s.mesoraca16@gmail.com> <CAGXu5jJTEoeGs8uBdHYdBJwacOp2b22ySrn-V8T93qaD4cv65A@mail.gmail.com>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Thu, 29 Jun 2017 21:28:11 +0200
Message-ID: <CAJHCu1JMdBCPgpL=vCqOKD1y4fK5Y3qoWOdXCy-qDw-ixV0Lmg@mail.gmail.com>
Subject: Re: [RFC v2 3/9] Creation of "check_vmflags" LSM hook
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-security-module <linux-security-module@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Smalley <sds@tycho.nsa.gov>, John Johansen <john.johansen@canonical.com>

2017-06-28 1:05 GMT+02:00 Kees Cook <keescook@chromium.org>:
> On Thu, Jun 15, 2017 at 9:42 AM, Salvatore Mesoraca
> <s.mesoraca16@gmail.com> wrote:
>> Creation of a new LSM hook to check if a given configuration of vmflags,
>> for a new memory allocation request, should be allowed or not.
>> It's placed in "do_mmap", "do_brk_flags" and "__install_special_mapping".
>
> I like this. I think this is something the other LSMs should be
> checking too. (Though I wonder if it would be helpful to include the
> VMA in the hook, though it does exist yet, so... hmm.)

For the particular case of my LSM and the type of check it does, the VMA
isn't needed, of course.
Maybe some other LSM can benefit from it, but it depends on what they
want to do with this hook.
Looking forward to feedback from potential future users.
Thank you for your interest.

Salvatore

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
