Date: Mon, 2 Aug 2004 09:37:37 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.SGI.4.58.0407161639110.118146@kzerza.americas.sgi.com>
Message-ID: <Pine.SGI.4.58.0408020936390.58090@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407152038160.8010-100000@localhost.localdomain>
 <Pine.SGI.4.58.0407161639110.118146@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jul 2004, Brent Casavant wrote:

> On Thu, 15 Jul 2004, Hugh Dickins wrote:
>
> > I'm as likely to find a 512P machine as a basilisk, so scalability
> > testing I leave to you.
>
> OK, I managed to grab some time on the machine today.  Parallel
> page faulting for /dev/zero and SysV shared memory has definitely
> improved in the first few test cases I have.

Hmm... This message must have come unwedged from a mail server somewhere.
You can mostly ignore it, unless you find it interesting.

Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
