Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4C6828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:42:33 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id z14so86070694igp.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:42:33 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id k11si512218iof.167.2016.01.08.15.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:42:32 -0800 (PST)
Received: by mail-ig0-x232.google.com with SMTP id ik10so89747403igb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:42:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrXEe0shSz25oB7yk4Ee5+y3AZJ6Kt3SANeBsmLCO7StKg@mail.gmail.com>
References: <cover.1452294700.git.luto@kernel.org>
	<CA+55aFxpGj2koqmcFF9JWzBeheF9473Ka516shwbuhfjVpgxrg@mail.gmail.com>
	<CALCETrXEe0shSz25oB7yk4Ee5+y3AZJ6Kt3SANeBsmLCO7StKg@mail.gmail.com>
Date: Fri, 8 Jan 2016 15:42:32 -0800
Message-ID: <CA+55aFxmc83LRHRSAsnydpqy4Y-K2V9RvRCU+dhV-kWzu2Gvpg@mail.gmail.com>
Subject: Re: [RFC 00/13] x86/mm: PCID and INVPCID
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 8, 2016 at 3:36 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>> Either things have changed (newer hardware with more pcids perhaps?)
>> or you did a better job at it.
>
> On my Skylake laptop, all of the PCID bits appear to have at least
> some effect.  Whether this means it gets hashed or whether this means
> that all of the bits are real, I don't know.

They have always gotten hashed, and no the bits aren't real - hardware
doesn't actually have as many bits in the pcid as there are in cr3.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
