Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA2282> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Mon, 07 Jul 2003 11:50:25 -0700
Date: Mon, 7 Jul 2003 11:36:31 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307071955.58774.phillips@arcor.de>
Message-ID: <Pine.LNX.4.55.0307071105110.4704@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <20030707152339.GA9669@mail.jlokier.co.uk>
 <Pine.LNX.4.55.0307071007140.4704@bigblue.dev.mcafeelabs.com>
 <200307071955.58774.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Jamie Lokier <jamie@shareable.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2003, Daniel Phillips wrote:

> On Monday 07 July 2003 19:25, Davide Libenzi wrote:
> >
> > Jamie, looking at those reports it seems it is not only a sound players
> > problem.
>
> You still seem to be having trouble with the idea that the sound servicing
> thread is a realtime process, and thus fundamentally different from other
> kinds of processes.  Could you please explain why you disagree with this?

I'm just trying to figure out why :

1) RealPlayer does not skip on my 2.4.20
2) RealPlayer does not skip on my office XP
3) MediaPlayer does not skip on my office XP

Maybe it is more of an application problem.


> > The *application* has to hint the scheduler, not the user.
>
> Partly true, in that users should be able to supply the hint in some way, they
> desire.  However in this case - Zinf - the point is moot, because Zinf is
> trying hard to give the hint, but it fails because of above-mentioned
> braindamage.

Try to play with SNDCTL_DSP_SETFRAGMENT. Last time I checked the kernel
let you set a dma buf for 0.5 up to 1 sec of play (upper limited by 64Kb).
Feeding the sound card with 4Kb writes will make you skip after about 50ms
CPU blackout at 44KHz 16 bit. RealPlayer uses 16Kb feeding chunks that
makes it able to sustain up to 200ms of blackout.



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
