Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA2262> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Mon, 07 Jul 2003 11:12:00 -0700
Date: Mon, 7 Jul 2003 10:58:06 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307071728.08753.phillips@arcor.de>
Message-ID: <Pine.LNX.4.55.0307071030210.4704@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.53.0307071408440.5007@skynet>
 <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
 <200307071728.08753.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Mel Gorman <mel@csn.ul.ie>, Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2003, Daniel Phillips wrote:

> That's not correct in this case, because the sound servicing routine is
> realtime, which makes it special.  Furthermore, Zinf is already trying to
> provide the kernel with the hint it needs via PThreads SetPriority but
> because Linux has brain damage - both in the kernel and user space imho - the
> hint isn't accomplishing what it's supposed to.
>
> As I said earlier: trying to detect automagically which threads are realtime
> and which aren't is stupid.  Such policy decisions don't belong in the
> kernel.

Having hacked a little bit with vsound I can say that many sound players
do not use at 100% the buffering the sound card/kernel is able to provide
and they still use 4-8Kb feeding chunks. That require very short timings
to not lose the time.



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
