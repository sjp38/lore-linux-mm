Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA1B99> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Sat, 05 Jul 2003 19:34:50 -0700
Date: Sat, 5 Jul 2003 19:21:02 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307060414.34827.phillips@arcor.de>
Message-ID: <Pine.LNX.4.55.0307051918310.4599@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <200307060010.26002.phillips@arcor.de>
 <20030706012857.GA29544@mail.jlokier.co.uk> <200307060414.34827.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jul 2003, Daniel Phillips wrote:

> On Sunday 06 July 2003 03:28, Jamie Lokier wrote:
> >
> > Your last point is most important.  At the moment, a SCHED_RR process
> > with a bug will basically lock up the machine, which is totally
> > inappropriate for a user app.
>
> How does the lockup come about?  As defined, a single SCHED_RR process could
> lock up only its own slice of CPU, as far as I can see.

They're de-queued and re-queue in the active array w/out having dynamic
priority adjustment (like POSIX states). This means that any task with
lower priority will starve if the RR task will not release the CPU.



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
