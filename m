Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13C156B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 15:45:16 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w125so10962827itf.0
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 12:45:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e9sor6521664ioe.155.2017.12.10.12.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Dec 2017 12:45:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1512641861-5113-1-git-send-email-geert+renesas@glider.be>
References: <1512641861-5113-1-git-send-email-geert+renesas@glider.be>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 10 Dec 2017 12:45:10 -0800
Message-ID: <CA+55aFzE0Z98KRT4rk3f3R0BcMqGMrHWHsaB9Aq02etwWm_hjg@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: Do not hash pointers when debugging slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 7, 2017 at 2:17 AM, Geert Uytterhoeven
<geert+renesas@glider.be> wrote:
>
>         if (cachep->flags & SLAB_STORE_USER) {
> -               pr_err("Last user: [<%p>](%pSR)\n",
> +               pr_err("Last user: [<%px>](%pSR)\n",
>                        *dbg_userword(cachep, objp),
>                        *dbg_userword(cachep, objp));

Is there actually any point to the %px at all?

Why not remove it? the _real_ information is printed out by %pSR, and
that's both sufficient and useful in ways %px isn't.

> -                               pr_err("Slab corruption (%s): %s start=%p, len=%d\n",
> +                               pr_err("Slab corruption (%s): %s start=%px, len=%d\n",
>                                        print_tainted(), cachep->name,
>                                        realobj, size);

and here, is the pointer actually interesting, or should we just give
the offset to the allocation?

But if the pointer is interesting, then ack.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
