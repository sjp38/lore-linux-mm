Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9H6ijhn314724
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 06:44:45 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9H6ijAd3281150
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 08:44:45 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9H6iimP015338
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 08:44:45 +0200
Message-ID: <48F83458.2080602@fr.ibm.com>
Date: Fri, 17 Oct 2008 08:44:40 +0200
From: Cedric Le Goater <clg@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu> <20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz> <20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz> <20081009134415.GA12135@elte.hu> <1223571036.11830.32.camel@nimitz> <20081010153951.GD28977@elte.hu> <48F30315.1070909@fr.ibm.com> <1223916223.29877.14.camel@nimitz> <48F6092D.6050400@fr.ibm.com> <48F685A3.1060804@cs.columbia.edu> <48F7352F.3020700@fr.ibm.com> <48F74674.20202@cs.columbia.edu> <87r66g8875.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87r66g8875.wl%peter@chubb.wattle.id.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrey Mirkin <major@openvz.org>
List-ID: <linux-mm.kvack.org>

> Oren> For now, yes. But we definitely want this capability in the long
> Oren> run; otherwise we won't be able to checkpoint a kernel compile
> Oren> ('make' uses vfork), or anything with 'gdb' running inside, or
> Oren> 'strace', and other goodies.
> 
> The strace/gdb example is *really* hard; but for vfork, you just wait
> until it's over. The interval between vfork and exec/exit should be
> short enough not to affect the overall time for a checkpoint (and
> checkpoint can be fairly slow anyway --- on the HPC machines we used
> to do it on, writing half a terabyte of checkpoint image to disc could take
> many minutes.  In hindsight, we should have multithreaded it).

we've tried that and it doesn't change a thing if you have only one disk :)
it might even give worse results as you are increasing context switches.

> Waiting for a vforked process to exec is less than a millisecond.

yes that shouldn't be too hard to handle.

Cheers,

C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
