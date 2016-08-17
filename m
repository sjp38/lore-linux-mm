Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2996B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 11:14:54 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e70so300764077ioi.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 08:14:54 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id n137si12061782ion.219.2016.08.17.08.14.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 08:14:53 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id y34so10627647ioi.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 08:14:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJ0OCR995Xu41SQvw2YQX-JUO5BhVyOuy0=wJ3Su07puw@mail.gmail.com>
References: <CAMuHMdU+j50GFT=DUWsx_dz1VJJ5zY2EVJi4cX4ZhVVLRMyjCA@mail.gmail.com>
 <CAGXu5jJ0OCR995Xu41SQvw2YQX-JUO5BhVyOuy0=wJ3Su07puw@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 17 Aug 2016 17:14:53 +0200
Message-ID: <CAMuHMdURgo0UB6961bZXkb-HV5P3wDT8hgHy=TcPRhA10GT2iw@mail.gmail.com>
Subject: Re: usercopy: kernel memory exposure attempt detected
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux MM <linux-mm@kvack.org>, "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

Hi Kees,

On Wed, Aug 17, 2016 at 4:52 PM, Kees Cook <keescook@chromium.org> wrote:
> On Wed, Aug 17, 2016 at 5:13 AM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
>> Saw this when using NFS root on r8a7791/koelsch, using a tree based on
>> renesas-drivers-2016-08-16-v4.8-rc2:
>>
>> usercopy: kernel memory exposure attempt detected from c01ff000
>> (<kernel text>) (4096 bytes)
>
> Hmmm, the kernel text exposure on ARM usually means the hardened
> usercopy patchset was applied to an ARM tree without the _etext patch:
> http://git.kernel.org/linus/14c4a533e0996f95a0a64dfd0b6252d788cebc74
>
> If you _do_ have this patch already (and based on the comment below, I
> suspect you do: usually the missing _etext makes the system entirely
> unbootable), then we need to dig further.

Yes, I do have that patch.

>> Despite the BUG(), the system continues working.
>
> I assume exim4 got killed, though?

Possibly. I don't really use email on the development boards.
Just a debootstrapped Debian NFS root.

> If you can figure out what bytes are present at c01ff000, that may
> give us a clue.

I've added a print_hex_dump(), so we'll find out when it happens again...

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
