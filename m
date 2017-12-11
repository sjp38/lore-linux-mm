Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E339D6B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 03:08:19 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id h4so20921637qtj.0
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 00:08:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l5sor9630672qkc.132.2017.12.11.00.08.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 00:08:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzE0Z98KRT4rk3f3R0BcMqGMrHWHsaB9Aq02etwWm_hjg@mail.gmail.com>
References: <1512641861-5113-1-git-send-email-geert+renesas@glider.be> <CA+55aFzE0Z98KRT4rk3f3R0BcMqGMrHWHsaB9Aq02etwWm_hjg@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 11 Dec 2017 09:08:15 +0100
Message-ID: <CAMuHMdUugcEPjN+1KoLocpe0GsoXoi5qeXMXvfQSbhm5XDjv7Q@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: Do not hash pointers when debugging slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Geert Uytterhoeven <geert+renesas@glider.be>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Linus,

On Sun, Dec 10, 2017 at 9:45 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Dec 7, 2017 at 2:17 AM, Geert Uytterhoeven
> <geert+renesas@glider.be> wrote:
>> -                               pr_err("Slab corruption (%s): %s start=%p, len=%d\n",
>> +                               pr_err("Slab corruption (%s): %s start=%px, len=%d\n",
>>                                        print_tainted(), cachep->name,
>>                                        realobj, size);
>
> and here, is the pointer actually interesting, or should we just give
> the offset to the allocation?

The pointer may help to identify e.g. an empty list_head in the written data.

> But if the pointer is interesting, then ack.

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
