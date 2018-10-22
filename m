Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62ACB6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 14:48:21 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g1-v6so4459439wrq.18
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 11:48:21 -0700 (PDT)
Received: from fuzix.org (www.llwyncelyn.cymru. [82.70.14.225])
        by mx.google.com with ESMTPS id f184-v6si10054884wme.36.2018.10.22.11.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Oct 2018 11:48:19 -0700 (PDT)
Date: Mon, 22 Oct 2018 19:48:17 +0100
From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20181022194817.148796e6@alans-desktop>
In-Reply-To: <20181022075642.icowfdg3y5wcam63@suse.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
	<20180830205527.dmemjwxfbwvkdzk2@suse.de>
	<alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
	<20180831070722.wnulbbmillxkw7ke@suse.de>
	<alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
	<20180911114927.gikd3uf3otxn2ekq@suse.de>
	<alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
	<20180911121128.ikwptix6e4slvpt2@suse.de>
	<20180918140030.248afa21@alans-desktop>
	<20181021123745.GA26042@amd>
	<20181022075642.icowfdg3y5wcam63@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Pavel Machek <pavel@ucw.cz>, Meelis Roos <mroos@linux.ee>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 22 Oct 2018 09:56:42 +0200
Joerg Roedel <jroedel@suse.de> wrote:

> On Sun, Oct 21, 2018 at 02:37:45PM +0200, Pavel Machek wrote:
> > On Tue 2018-09-18 14:00:30, Alan Cox wrote:  
> > > There are pretty much no machines that don't support PAE and are still
> > > even vaguely able to boot a modern Linux kernel. The oddity is the
> > > Pentium-M but most distros shipped a hack to use PAE on the Pentium M
> > > anyway as it seems to work fine.  
> > 
> > I do have some AMD Geode here, in form of subnotebook. Definitely
> > newer then Pentium Ms, but no PAE...  
> 
> Are the AMD Geode chips affected by Meltdown?

Geode for AMD was just a marketing name.

The AMD athlon labelled as 'Geode' will behave like any other Athlon but
I've not seen anyone successfully implement Meltdown on the Athlon so it's
probably ok. 

The earlier NatSemi ones are not AFAIK vulnerable to either. The later
ones might do Spectre (they have branch prediction which is disabled on
the earlier ones) but quite possibly not enough to be attacked usefully -
and you can turn it off anyway if you care.

And I doubt your subnotebook can usefully run modern Linux since the
memory limit on most Geode was about 64MB.

Alan
