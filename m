Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9FE48E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 15:49:31 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id p21so22463itb.8
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:49:31 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id k188si26735itc.22.2018.12.10.12.49.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Dec 2018 12:49:30 -0800 (PST)
Message-ID: <8a2e104a6c5b745adca8e7f3310af564f3b8a75d.camel@kernel.crashing.org>
Subject: Re: use generic DMA mapping code in powerpc V4
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 11 Dec 2018 07:49:21 +1100
In-Reply-To: <20181210193317.GA31514@lst.de>
References: 
	<CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
	 <20181130103222.GA23393@lst.de>
	 <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
	 <42b1408cafe77ebac1b1ad909db237fe34e4d177.camel@kernel.crashing.org>
	 <20181208171746.GB15228@lst.de>
	 <CALjTZvb4+Ox5Jdm-xwQuxMDz_ub=mHAgPLA4NgrVNZTmUZwhnQ@mail.gmail.com>
	 <20181210193317.GA31514@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Rui Salvaterra <rsalvaterra@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Mon, 2018-12-10 at 20:33 +0100, Christoph Hellwig wrote:
> On Mon, Dec 10, 2018 at 05:04:46PM +0000, Rui Salvaterra wrote:
> > Hi, Christoph and Ben,
> > 
> > It just came to my mind (and this is most likely a stupid question,
> > but still)… Is there any possibility of these changes having an
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

AGP is a gigantic nightmare :-) It's not just cache coherency issues
(some implementations are coherent, some aren't, Apple's is ... weird).

Apple has all sort of bugs, and Darwin source code only sheds light on
some of them. Some implementation can only read, not write I think, for
example. There are issues with transfers crossing some boundaries I
beleive, but it's all unclear.

Apple makes this work with a combination of hacks in the AGP "driver"
and the closed source GPU driver, which we don't see.

I have given up trying to make that stuff work reliably a decade ago :)

Cheers,
Ben.
