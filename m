From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load
Date: Thu, 19 Apr 2001 21:14:48 +0100
Message-ID: <rnhudtssc00ia2r1unis96lfjd2slb8mup@4ax.com>
References: <1809062307.20010319210655@dragon.cz>
In-Reply-To: <1809062307.20010319210655@dragon.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: happz <happz@dragon.cz>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Mar 2001 21:06:55 +0100, you wrote:

>What about this: give to process way how to tell kernel "it is not
>good to suspend me, because there are process' that depend on me and
>wouldn't be blocked." Syscall or /proc filesystem could be used.
>
>It is not the way how to say which process should be suspended but a
>way how to say which could NOT - usefull for example for X server, may
>be some daemons, aso.

Possibly; TBH, I don't think it's worth it. Remember, "suspending" X
would just stop your mouse moving etc. for (e.g.) 5 seconds; in fact,
that should block most graphical processes, which may well resolve the
thrashing in itself!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
