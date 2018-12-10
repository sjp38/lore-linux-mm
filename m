Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD708E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 14:33:20 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id d11so3775026wrq.18
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:33:20 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n3si7578565wrq.366.2018.12.10.11.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 11:33:18 -0800 (PST)
Date: Mon, 10 Dec 2018 20:33:17 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181210193317.GA31514@lst.de>
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com> <20181130103222.GA23393@lst.de> <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com> <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org> <20181208171746.GB15228@lst.de> <CALjTZvb4+Ox5Jdm-xwQuxMDz_ub=mHAgPLA4NgrVNZTmUZwhnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALjTZvb4+Ox5Jdm-xwQuxMDz_ub=mHAgPLA4NgrVNZTmUZwhnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: hch@lst.de, benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Mon, Dec 10, 2018 at 05:04:46PM +0000, Rui Salvaterra wrote:
> Hi, Christoph and Ben,
> 
> It just came to my mind (and this is most likely a stupid question,
> but still)… Is there any possibility of these changes having an
> (positive) effect on the long-standing problem of Power Mac machines
> with AGP graphics cards (which have to be limited to PCI transfers,
> otherwise they'll hang, due to coherence issues)? If so, I have a G4
> machine where I'd gladly test them.

These patches themselves are not going to affect that directly.
But IFF the problem really is that the AGP needs to be treated as not
cache coherent (I have no idea if that is true) the generic direct
mapping code has full support for a per-device coherent flag, so
support for a non-coherent AGP slot could be implemented relatively
simply.
