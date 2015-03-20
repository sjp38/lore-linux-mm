Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id A0B8B6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:01:29 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so100589881iec.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:01:29 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id ke13si5340529icb.101.2015.03.20.11.53.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 11:53:35 -0700 (PDT)
Received: by igbqf9 with SMTP id qf9so704703igb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 11:53:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550C6151.8070803@oracle.com>
References: <550C37C9.2060200@oracle.com>
	<CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>
	<550C5078.8040402@oracle.com>
	<CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
	<550C6151.8070803@oracle.com>
Date: Fri, 20 Mar 2015 11:53:35 -0700
Message-ID: <CA+55aFyE-zA3be7=FWZE_m2hVHwZueGvciSrghhQB3gT-UHrPA@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

On Fri, Mar 20, 2015 at 11:05 AM, David Ahern <david.ahern@oracle.com> wrote:
>
> Evidently, it is a well known problem internally that goes back to at least
> 2.6.39.
>
> To this point I have not paid attention to the allocators. At what point is
> SLUB considered stable for large systems? Is 2.6.39 stable?

SLUB should definitely be considered a stable allocator.  It's the
default allocator for at least Fedora, and that presumably means all
of Redhat.

SuSE seems to use SLAB still, though, so it must be getting lots of
testing on x86 too.

Did you test with SLUB? Does it work there?

> As for SLAB it is not clear if this is a sparc only problem. Perhaps the
> config should have a warning? It looks like SLAB is still the default for
> most arch.

I definitely think SLAB should work (although I *would* like to get
rid of the duplicate allocators), and I still do think it's likely a
sparc issue. Especially as it apparently goes way back. x86 gets a
*lot* more testing, and I don't really recall anything like this.

I'm not comfy enough reading sparc asm code to really pinpoint exactly
what looks to go wrong, so I have very little input on what the
problem could be.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
