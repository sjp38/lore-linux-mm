Date: Mon, 12 Jul 2004 14:55:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040712215504.GN21066@holomorphy.com>
References: <Pine.SGI.4.58.0407121546460.111008@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.58.0407121546460.111008@kzerza.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 12, 2004 at 04:11:29PM -0500, Brent Casavant wrote:
> Looking at this code, I don't see any straightforward way to alleviate
> this problem.  So, I was wondering if you might have any ideas how one
> might approach this.  I'm hoping for something that will give us good
> scaling all the way up to 512P.

Smells like per-cpu split counter material to me.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
