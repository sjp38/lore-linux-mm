Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3764D6B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 16:59:43 -0400 (EDT)
Received: by iyn15 with SMTP id 15so12016757iyn.34
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 13:59:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
	<1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
Date: Mon, 22 Aug 2011 22:59:40 +0200
Message-ID: <CAMuHMdVUvLAYpGDKsDUJ0DkLJEJKHCRy2Cj6miAH1YyEL6iWpw@mail.gmail.com>
Subject: Re: [PATCH 3/4] string: introduce memchr_inv
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joern Engel <joern@logfs.org>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, Aug 22, 2011 at 18:29, Akinobu Mita <akinobu.mita@gmail.com> wrote:
> +/**
> + * memchr_inv - Find a character in an area of memory.

This description doesn't really match.

> + * @s: The memory area
> + * @c: The byte to search for
> + * @n: The size of the area.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
