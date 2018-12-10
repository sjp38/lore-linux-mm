Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16F578E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:05:01 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id t136so6615665vsc.12
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:05:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g126sor5662751vka.31.2018.12.10.09.04.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 09:04:59 -0800 (PST)
MIME-Version: 1.0
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
 <20181130103222.GA23393@lst.de> <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
 <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org> <20181208171746.GB15228@lst.de>
In-Reply-To: <20181208171746.GB15228@lst.de>
From: Rui Salvaterra <rsalvaterra@gmail.com>
Date: Mon, 10 Dec 2018 17:04:46 +0000
Message-ID: <CALjTZvb4+Ox5Jdm-xwQuxMDz_ub=mHAgPLA4NgrVNZTmUZwhnQ@mail.gmail.com>
Subject: Re: use generic DMA mapping code in powerpc V4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@lst.de
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat, 8 Dec 2018 at 17:17, Christoph Hellwig <hch@lst.de> wrote:
>
> On Sun, Dec 02, 2018 at 05:11:02PM +1100, Benjamin Herrenschmidt wrote:
> > Talking of which ... Christoph, not sure if we can do something about
> > this at the DMA API level or keep hacks but some adapters such as the
> > nVidia GPUs have a HW hack we can use to work around their limitations
> > in that case.
> >
> > They have a register that can program a fixed value for the top bits
> > that they don't support.
> >
> > This works fine for any linear mapping with an offset, provided they
> > can program the offset in that register and they have enough DMA range
> > to cover all memory from that offset.
> >
> > I can probably get the info about this from them so we can exploit it
> > in nouveau.
>
> I think we can expose the direct mapping offset if people care enough,
> we just have to be very careful designing the API.  I'll happily leave
> that to those that actually want to use it, but I'll gladly help
> reviewing it.

Hi, Christoph and Ben,

It just came to my mind (and this is most likely a stupid question,
but still)=E2=80=A6 Is there any possibility of these changes having an
(positive) effect on the long-standing problem of Power Mac machines
with AGP graphics cards (which have to be limited to PCI transfers,
otherwise they'll hang, due to coherence issues)? If so, I have a G4
machine where I'd gladly test them.

Thanks,

Rui
