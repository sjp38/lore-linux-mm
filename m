Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB916B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:56:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e49-v6so20253859edd.20
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:56:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y18-v6si4044114ejp.13.2018.10.22.00.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 00:56:43 -0700 (PDT)
Date: Mon, 22 Oct 2018 09:56:42 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20181022075642.icowfdg3y5wcam63@suse.de>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181021123745.GA26042@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Meelis Roos <mroos@linux.ee>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Oct 21, 2018 at 02:37:45PM +0200, Pavel Machek wrote:
> On Tue 2018-09-18 14:00:30, Alan Cox wrote:
> > There are pretty much no machines that don't support PAE and are still
> > even vaguely able to boot a modern Linux kernel. The oddity is the
> > Pentium-M but most distros shipped a hack to use PAE on the Pentium M
> > anyway as it seems to work fine.
> 
> I do have some AMD Geode here, in form of subnotebook. Definitely
> newer then Pentium Ms, but no PAE...

Are the AMD Geode chips affected by Meltdown?


Regards,

	Joerg
