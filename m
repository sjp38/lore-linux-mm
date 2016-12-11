Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 127AF6B0069
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 14:14:17 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 12so83083056uas.5
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 11:14:17 -0800 (PST)
Received: from mail-ua0-x236.google.com (mail-ua0-x236.google.com. [2607:f8b0:400c:c08::236])
        by mx.google.com with ESMTPS id w35si10292190uaw.238.2016.12.11.11.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 11:14:16 -0800 (PST)
Received: by mail-ua0-x236.google.com with SMTP id 12so63989712uas.2
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 11:14:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161209230851.GB64048@google.com>
References: <20161209230851.GB64048@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 11 Dec 2016 11:13:55 -0800
Message-ID: <CALCETrVBGPijiacbY-trdbgRPYC8grNrGA7TVu0xvxUaqud08w@mail.gmail.com>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Herbert Xu <herbert@gondor.apana.org.au>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Fri, Dec 9, 2016 at 3:08 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> In the 4.9 kernel, virtually-mapped stacks will be supported and enabled by
> default on x86_64.  This has been exposing a number of problems in which
> on-stack buffers are being passed into the crypto API, which to support crypto
> accelerators operates on 'struct page' rather than on virtual memory.
>

>         fs/cifs/smbencrypt.c:96

This should use crypto_cipher_encrypt_one(), I think.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
