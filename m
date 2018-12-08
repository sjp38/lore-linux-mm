Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69E818E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 12:17:48 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id 49so2410456wra.14
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 09:17:48 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 140si4902294wme.61.2018.12.08.09.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Dec 2018 09:17:47 -0800 (PST)
Date: Sat, 8 Dec 2018 18:17:46 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181208171746.GB15228@lst.de>
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com> <20181130103222.GA23393@lst.de> <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com> <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Rui Salvaterra <rsalvaterra@gmail.com>, hch@lst.de, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sun, Dec 02, 2018 at 05:11:02PM +1100, Benjamin Herrenschmidt wrote:
> Talking of which ... Christoph, not sure if we can do something about
> this at the DMA API level or keep hacks but some adapters such as the
> nVidia GPUs have a HW hack we can use to work around their limitations
> in that case.
> 
> They have a register that can program a fixed value for the top bits
> that they don't support.
> 
> This works fine for any linear mapping with an offset, provided they
> can program the offset in that register and they have enough DMA range
> to cover all memory from that offset.
> 
> I can probably get the info about this from them so we can exploit it
> in nouveau.

I think we can expose the direct mapping offset if people care enough,
we just have to be very careful designing the API.  I'll happily leave
that to those that actually want to use it, but I'll gladly help
reviewing it.
