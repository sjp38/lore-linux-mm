Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 371BF8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:37:15 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id w22so7838480vsj.15
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:37:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z17sor7256736uao.49.2018.12.11.01.37.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 01:37:14 -0800 (PST)
MIME-Version: 1.0
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
 <20181130103222.GA23393@lst.de> <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
 <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org>
 <20181208171746.GB15228@lst.de> <CALjTZvb4+Ox5Jdm-xwQuxMDz_ub=mHAgPLA4NgrVNZTmUZwhnQ@mail.gmail.com>
 <20181210193317.GA31514@lst.de> <8a2e104a6c5b745adca8e7f3310af564f3b8a75d.camel@kernel.crashing.org>
In-Reply-To: <8a2e104a6c5b745adca8e7f3310af564f3b8a75d.camel@kernel.crashing.org>
From: Rui Salvaterra <rsalvaterra@gmail.com>
Date: Tue, 11 Dec 2018 09:37:02 +0000
Message-ID: <CALjTZvZ1Ud4P_XqB23Yq=815VyF=UbbT8YCFjTaPN=5tORWrtQ@mail.gmail.com>
Subject: Re: use generic DMA mapping code in powerpc V4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: hch@lst.de, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Mon, 10 Dec 2018 at 20:49, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
>

[snip]

>
> AGP is a gigantic nightmare :-) It's not just cache coherency issues
> (some implementations are coherent, some aren't, Apple's is ... weird).
>
> Apple has all sort of bugs, and Darwin source code only sheds light on
> some of them. Some implementation can only read, not write I think, for
> example. There are issues with transfers crossing some boundaries I
> beleive, but it's all unclear.
>
> Apple makes this work with a combination of hacks in the AGP "driver"
> and the closed source GPU driver, which we don't see.
>
> I have given up trying to make that stuff work reliably a decade ago :)
>
> Cheers,
> Ben.

That's what I was afraid of=E2=80=A6 what a mess. At least now I have a
definitive answer from one of the original authors of the code, thanks
a lot, Ben. :)
I have an unresearched belief that AGP support was hacked in the Mac
series as an afterthought (weren't they supposed to be PCI/PCI-X
only?), and your explanation surely seems to corroborate. :/
