Date: Mon, 7 Jul 2003 14:16:05 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307071424.06393.phillips@arcor.de>
Message-ID: <Pine.LNX.4.53.0307071408440.5007@skynet>
References: <20030703023714.55d13934.akpm@osdl.org> <200307060414.34827.phillips@arcor.de>
 <Pine.LNX.4.53.0307071042470.743@skynet> <200307071424.06393.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2003, Daniel Phillips wrote:

> And set up distros to grant it by default.  Yes.
>
> The problem I see is that it lets user space priorities invade the range of
> priorities used by root processes.

That is the main drawback all right but it could be addressed by having a
CAP_SYS_USERNICE capability which allows a user to renice only their own
processes to a highest priority of -5, or some other reasonable value
that wouldn't interfere with root processes. This capability would only be
for applications like music players which need to give hints to the
scheduler.

This would make it a bit Linux specific but as the pam module (currently
vapour I know) is the only piece of code that would be aware of the
distinction, it should not be much of a problem.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
