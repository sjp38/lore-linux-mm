Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA33CA> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 09 Jul 2003 15:44:01 -0700
Date: Wed, 9 Jul 2003 15:29:59 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <20030709222426.GA24923@mail.jlokier.co.uk>
Message-ID: <Pine.LNX.4.55.0307091524240.4625@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org>
 <Pine.LNX.4.55.0307071007140.4704@bigblue.dev.mcafeelabs.com>
 <20030707193628.GA10836@mail.jlokier.co.uk> <200307082027.13857.phillips@arcor.de>
 <20030709222426.GA24923@mail.jlokier.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Daniel Phillips <phillips@arcor.de>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jul 2003, Jamie Lokier wrote:

> Indeed.  But maybe true (bounded CPU) realtime, reliable, would more
> accurately reflect what the user actually wants for some apps?

Hopefully I'll have a couple of hours free to code and test the
SCHED_SOFTRR idea ;) It's hard to push for a new POSIX definition though :)
Looking at recent posts it seems that this is not the only problem though.
It seems interactivity lowered in the latest versions of the scheduler.
The good news is that Ingo is back on Earth and he'll fix it :)



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
