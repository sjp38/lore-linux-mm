Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6C01D828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:31:04 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id 77so270537687ioc.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:31:04 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id z9si17753309ioi.192.2016.01.08.15.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:31:03 -0800 (PST)
Received: by mail-ig0-x230.google.com with SMTP id z14so67825059igp.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:31:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Date: Fri, 8 Jan 2016 15:31:03 -0800
Message-ID: <CA+55aFxpGj2koqmcFF9JWzBeheF9473Ka516shwbuhfjVpgxrg@mail.gmail.com>
Subject: Re: [RFC 00/13] x86/mm: PCID and INVPCID
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 8, 2016 at 3:15 PM, Andy Lutomirski <luto@kernel.org> wrote:
>
> Please play around and suggest (and run?) good benchmarks.  It seems
> to save around 100ns on cross-process context switches for me.

Interesting. There was reportedly (I never saw it) a test-patch to use
pcids inside of Intel a couple of years ago, and it never got outside
because it didn't make a difference.

Either things have changed (newer hardware with more pcids perhaps?)
or you did a better job at it.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
