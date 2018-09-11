Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3A88E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 07:58:15 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id f2-v6so4628386lff.12
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 04:58:15 -0700 (PDT)
Received: from smtp1.it.da.ut.ee (smtp1.it.da.ut.ee. [2001:bb8:2002:500::46])
        by mx.google.com with ESMTP id m13-v6si19233914lfl.18.2018.09.11.04.58.13
        for <linux-mm@kvack.org>;
        Tue, 11 Sep 2018 04:58:13 -0700 (PDT)
Date: Tue, 11 Sep 2018 14:58:10 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: 32-bit PTI with THP = userspace corruption
In-Reply-To: <20180911114927.gikd3uf3otxn2ekq@suse.de>
Message-ID: <alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee> <20180830205527.dmemjwxfbwvkdzk2@suse.de> <alpine.LRH.2.21.1808310711380.17865@math.ut.ee> <20180831070722.wnulbbmillxkw7ke@suse.de> <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
 <20180911114927.gikd3uf3otxn2ekq@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

> 	4) Disable PTI support on 2-level paging by making it dependent
> 	   on CONFIG_X86_PAE. This is, imho, the least ugly option
> 	   because the machines that do not support PAE are most likely
> 	   too old to be affected my Meltdown anyway. We might also
> 	   consider switching i386_defconfig to PAE?
> 
> Any other thoughts?

The machines where I have PAE off are the ones that have less memory. 
PAE is off just for performance reasons, not lack of PAE. PAE should be 
present on all of my affected machines anyway and current distributions 
seem to mostly assume 686 and PAE anyway for 32-bit systems.

-- 
Meelis Roos (mroos@ut.ee)      http://www.cs.ut.ee/~mroos/
