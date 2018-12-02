Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A97A76B61F3
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 01:11:15 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id p141so1988096ywg.17
        for <linux-mm@kvack.org>; Sat, 01 Dec 2018 22:11:15 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id a93-v6si6119636ybi.258.2018.12.01.22.11.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 01 Dec 2018 22:11:14 -0800 (PST)
Message-ID: <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org>
Subject: Re: use generic DMA mapping code in powerpc V4
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 02 Dec 2018 17:11:02 +1100
In-Reply-To: <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
References: 
	  <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
	 <20181130103222.GA23393@lst.de>
	 <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>, hch@lst.de
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Fri, 2018-11-30 at 11:44 +0000, Rui Salvaterra wrote:
> Thanks for the quick response! I applied it on top of your
> powerpc-dma.4 branch and retested.
> I'm not seeing nouveau complaining anymore (I'm not using X11 or any
> DE, though).
> In any case and FWIW, this series is
> 
> Tested-by: Rui Salvaterra <rsalvaterra@gmail.com>

Talking of which ... Christoph, not sure if we can do something about
this at the DMA API level or keep hacks but some adapters such as the
nVidia GPUs have a HW hack we can use to work around their limitations
in that case.

They have a register that can program a fixed value for the top bits
that they don't support.

This works fine for any linear mapping with an offset, provided they
can program the offset in that register and they have enough DMA range
to cover all memory from that offset.

I can probably get the info about this from them so we can exploit it
in nouveau.

Cheers,
Ben.

> Thanks,
> Rui
