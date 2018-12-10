Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1B888E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 15:04:03 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id r133so7049705vsc.3
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:04:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor6517938uak.12.2018.12.10.12.04.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 12:04:02 -0800 (PST)
MIME-Version: 1.0
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
 <20181130103222.GA23393@lst.de> <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
 <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org>
 <20181208171746.GB15228@lst.de> <CALjTZvb4+Ox5Jdm-xwQuxMDz_ub=mHAgPLA4NgrVNZTmUZwhnQ@mail.gmail.com>
 <20181210193317.GA31514@lst.de>
In-Reply-To: <20181210193317.GA31514@lst.de>
From: Rui Salvaterra <rsalvaterra@gmail.com>
Date: Mon, 10 Dec 2018 20:03:49 +0000
Message-ID: <CALjTZvZNNj7L6MWg=xdA31xbfwW_8gej5iUPXqz4Xg55EQUYSA@mail.gmail.com>
Subject: Re: use generic DMA mapping code in powerpc V4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@lst.de
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Mon, 10 Dec 2018 at 19:33, Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Dec 10, 2018 at 05:04:46PM +0000, Rui Salvaterra wrote:
> > Hi, Christoph and Ben,
> >
> > It just came to my mind (and this is most likely a stupid question,
> > but still)=E2=80=A6 Is there any possibility of these changes having an
> > (positive) effect on the long-standing problem of Power Mac machines
> > with AGP graphics cards (which have to be limited to PCI transfers,
> > otherwise they'll hang, due to coherence issues)? If so, I have a G4
> > machine where I'd gladly test them.
>
> These patches themselves are not going to affect that directly.
> But IFF the problem really is that the AGP needs to be treated as not
> cache coherent (I have no idea if that is true) the generic direct
> mapping code has full support for a per-device coherent flag, so
> support for a non-coherent AGP slot could be implemented relatively
> simply.

Thanks for the insight, Christoph. Well, the problem[1] is real, and
it's been known for a long time, though I can't be sure if it's *only*
a coherence issue. If someone who knows the hardware manages to cook
up a patch (as hacky is it may be), I'll definitely fire up old my G4
laptop to test it! :)

[1] https://bugs.freedesktop.org/show_bug.cgi?id=3D95017
