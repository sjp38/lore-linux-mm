Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA2189> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Mon, 07 Jul 2003 08:01:07 -0700
Date: Mon, 7 Jul 2003 07:47:14 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <Pine.LNX.4.53.0307071408440.5007@skynet>
Message-ID: <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <200307060414.34827.phillips@arcor.de>
 <Pine.LNX.4.53.0307071042470.743@skynet> <200307071424.06393.phillips@arcor.de>
 <Pine.LNX.4.53.0307071408440.5007@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Daniel Phillips <phillips@arcor.de>, Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2003, Mel Gorman wrote:

> On Mon, 7 Jul 2003, Daniel Phillips wrote:
>
> > And set up distros to grant it by default.  Yes.
> >
> > The problem I see is that it lets user space priorities invade the range of
> > priorities used by root processes.
>
> That is the main drawback all right but it could be addressed by having a
> CAP_SYS_USERNICE capability which allows a user to renice only their own
> processes to a highest priority of -5, or some other reasonable value
> that wouldn't interfere with root processes. This capability would only be
> for applications like music players which need to give hints to the
> scheduler.

The scheduler has to work w/out external input, period. If it doesn't we
have to fix it and not to force the user to submit external hints.



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
