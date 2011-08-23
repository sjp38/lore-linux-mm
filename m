Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 485396B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 10:31:26 -0400 (EDT)
Date: Tue, 23 Aug 2011 09:31:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] string: introduce memchr_inv
In-Reply-To: <CAMuHMdVUvLAYpGDKsDUJ0DkLJEJKHCRy2Cj6miAH1YyEL6iWpw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1108230931000.21267@router.home>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com> <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com> <CAMuHMdVUvLAYpGDKsDUJ0DkLJEJKHCRy2Cj6miAH1YyEL6iWpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joern Engel <joern@logfs.org>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, 22 Aug 2011, Geert Uytterhoeven wrote:

> On Mon, Aug 22, 2011 at 18:29, Akinobu Mita <akinobu.mita@gmail.com> wrote:
> > +/**
> > + * memchr_inv - Find a character in an area of memory.
>
> This description doesn't really match.

Seconded. If you fix that then

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
