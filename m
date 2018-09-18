Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAD7E8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 09:00:33 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k1-v6so1872009wrl.13
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 06:00:33 -0700 (PDT)
Received: from fuzix.org (www.llwyncelyn.cymru. [82.70.14.225])
        by mx.google.com with ESMTPS id a34-v6si18042142wrc.100.2018.09.18.06.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Sep 2018 06:00:32 -0700 (PDT)
Date: Tue, 18 Sep 2018 14:00:30 +0100
From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20180918140030.248afa21@alans-desktop>
In-Reply-To: <20180911121128.ikwptix6e4slvpt2@suse.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
	<20180830205527.dmemjwxfbwvkdzk2@suse.de>
	<alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
	<20180831070722.wnulbbmillxkw7ke@suse.de>
	<alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
	<20180911114927.gikd3uf3otxn2ekq@suse.de>
	<alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
	<20180911121128.ikwptix6e4slvpt2@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Meelis Roos <mroos@linux.ee>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 11 Sep 2018 14:12:22 +0200
Joerg Roedel <jroedel@suse.de> wrote:

> On Tue, Sep 11, 2018 at 02:58:10PM +0300, Meelis Roos wrote:
> > The machines where I have PAE off are the ones that have less memory. 
> > PAE is off just for performance reasons, not lack of PAE. PAE should be 
> > present on all of my affected machines anyway and current distributions 
> > seem to mostly assume 686 and PAE anyway for 32-bit systems.  
> 
> Right, most distributions don't even provide a non-PAE kernel for their
> users anymore.
> 
> How big is the performance impact of using PAE over legacy paging?

On what system. In the days of the original 36bit PAE Xeons it was around
10% when we measured it at Red Hat, but that was long ago and as you go
newer it really ought to be vanishingly small.

There are pretty much no machines that don't support PAE and are still
even vaguely able to boot a modern Linux kernel. The oddity is the
Pentium-M but most distros shipped a hack to use PAE on the Pentium M
anyway as it seems to work fine.

Alan
