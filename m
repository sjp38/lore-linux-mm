Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA2213> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Mon, 07 Jul 2003 10:39:33 -0700
Date: Mon, 7 Jul 2003 10:25:36 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <20030707152339.GA9669@mail.jlokier.co.uk>
Message-ID: <Pine.LNX.4.55.0307071007140.4704@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <200307060414.34827.phillips@arcor.de>
 <Pine.LNX.4.53.0307071042470.743@skynet> <200307071424.06393.phillips@arcor.de>
 <Pine.LNX.4.53.0307071408440.5007@skynet> <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
 <20030707152339.GA9669@mail.jlokier.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2003, Jamie Lokier wrote:

> Davide Libenzi wrote:
> > The scheduler has to work w/out external input, period.
>
> Can you justify this?
>
> It strikes me that a music player's thread which requests a special
> music-playing scheduling hint is not unreasonable, if that actually
> works and scheduler heuristics do not.

Jamie, looking at those reports it seems it is not only a sound players
problem. It is fine that an application that has strict timing issues
hints the scheduler. The *application* has to hint the scheduler, not the
user. If reports about UI interactivity are true, this means that there's
something wrong in the current scheduler though. Besides the player issue.



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
