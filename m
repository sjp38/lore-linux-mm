Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7C536B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:01:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s63so13240109ioi.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:01:39 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id q76si12099279oic.149.2016.06.14.23.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 23:01:39 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id p204so18531981oih.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:01:39 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 14 Jun 2016 23:01:19 -0700
Message-ID: <CALCETrWMh0+_RKV1OwwqE6s8P=fLFUYcAxvSNwDK_qB6BOBs9w@mail.gmail.com>
Subject: Playing with virtually mapped stacks (with guard pages!)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all-

If you want to play with virtually mapped stacks, I have it more or
less working on x86 in a branch here:

https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/vmap_stack

The core bit (virtually map the stack and fix the accounting) is just
a config option, but it needs the arch to opt-in.  I suspect that
every arch will have its own set of silly issues to address to make it
work well.  For x86, the silly issues are getting the OOPS to work
right and handling some vmalloc_fault oddities to avoid panicing at
random.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
