Date: Thu, 15 Jul 2004 16:52:37 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.LNX.4.44.0407152038160.8010-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407151647100.116400@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407152038160.8010-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jul 2004, Hugh Dickins wrote:

> +	/* Keep it simple: disallow limited <-> unlimited remount */
> +	if ((max_blocks || max_inodes) == !sbinfo)
> +		return -EINVAL;

Just caught this one.

Shouldn't this be:

	if ((max_blocks || max_inodes) && !sbinfo)
		return -EINVAL;

Otherwise I think it looks good, though I don't understand some parts
of it of course.  I'm pretty sure it solves the SysV shared memory
scaling problem as well, just by visual inspection.

I'll give the patch a whirl when I can next schedule time on our 512P.

Thanks,
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
