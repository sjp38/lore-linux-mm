Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03F996B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 07:01:43 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 207so14078200iti.5
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 04:01:43 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [69.252.207.37])
        by mx.google.com with ESMTPS id e41si10212815ioj.46.2017.12.11.04.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 04:01:42 -0800 (PST)
Date: Mon, 11 Dec 2017 06:00:40 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: Do not hash pointers when debugging slab
In-Reply-To: <CA+55aFzE0Z98KRT4rk3f3R0BcMqGMrHWHsaB9Aq02etwWm_hjg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712110558560.19414@nuc-kabylake>
References: <1512641861-5113-1-git-send-email-geert+renesas@glider.be> <CA+55aFzE0Z98KRT4rk3f3R0BcMqGMrHWHsaB9Aq02etwWm_hjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Geert Uytterhoeven <geert+renesas@glider.be>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, 10 Dec 2017, Linus Torvalds wrote:

> On Thu, Dec 7, 2017 at 2:17 AM, Geert Uytterhoeven
> <geert+renesas@glider.be> wrote:
> >
> >         if (cachep->flags & SLAB_STORE_USER) {
> > -               pr_err("Last user: [<%p>](%pSR)\n",
> > +               pr_err("Last user: [<%px>](%pSR)\n",
> >                        *dbg_userword(cachep, objp),
> >                        *dbg_userword(cachep, objp));
>
> Is there actually any point to the %px at all?
>
> Why not remove it? the _real_ information is printed out by %pSR, and
> that's both sufficient and useful in ways %px isn't.

This pointer refers to code so we can remove it.

>
> > -                               pr_err("Slab corruption (%s): %s start=%p, len=%d\n",
> > +                               pr_err("Slab corruption (%s): %s start=%px, len=%d\n",
> >                                        print_tainted(), cachep->name,
> >                                        realobj, size);
>
> and here, is the pointer actually interesting, or should we just give
> the offset to the allocation?
>
> But if the pointer is interesting, then ack.

The pointer here is to an slab object which could be important if one
wants to find the pointer value  in a hexdump of another object (f.e.
listhead) or other pointer information that is being inspected
in a debugging session.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
