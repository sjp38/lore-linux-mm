Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id DD989828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:36:33 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id k206so20687485oia.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:36:33 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id rl4si868471oeb.36.2016.01.08.15.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:36:33 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id ba1so367197849obb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:36:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxpGj2koqmcFF9JWzBeheF9473Ka516shwbuhfjVpgxrg@mail.gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <CA+55aFxpGj2koqmcFF9JWzBeheF9473Ka516shwbuhfjVpgxrg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 8 Jan 2016 15:36:13 -0800
Message-ID: <CALCETrXEe0shSz25oB7yk4Ee5+y3AZJ6Kt3SANeBsmLCO7StKg@mail.gmail.com>
Subject: Re: [RFC 00/13] x86/mm: PCID and INVPCID
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 8, 2016 at 3:31 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Jan 8, 2016 at 3:15 PM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> Please play around and suggest (and run?) good benchmarks.  It seems
>> to save around 100ns on cross-process context switches for me.
>
> Interesting. There was reportedly (I never saw it) a test-patch to use
> pcids inside of Intel a couple of years ago, and it never got outside
> because it didn't make a difference.

I have a copy of that patch, and my code works very differently.  I
only use 3 bits of PCID in this series.  I could probably reduce that
to 2 with little loss.  4 or more would be a waste.

>
> Either things have changed (newer hardware with more pcids perhaps?)
> or you did a better job at it.

On my Skylake laptop, all of the PCID bits appear to have at least
some effect.  Whether this means it gets hashed or whether this means
that all of the bits are real, I don't know.  I'll fiddle with it on
an older machine.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
