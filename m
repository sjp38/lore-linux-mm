Date: Thu, 29 Jul 2004 16:51:26 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.SGI.4.58.0407291614150.35081@kzerza.americas.sgi.com>
Message-ID: <Pine.SGI.4.58.0407291650050.35081@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
 <Pine.SGI.4.58.0407291614150.35081@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2004, Brent Casavant wrote:

> On Thu, 29 Jul 2004, Hugh Dickins wrote:

> > Why doesn't the creator of the shm segment or /dev/zero mapping just
> > fault in all the pages before handing over to the other threads?
>
> Performance.  The mapping could well range into the tens or hundreds
> of gigabytes, and faulting these pages in parallel would certainly
> be advantageous.

Oh, and let me clarify something.  I don't think anyone currently
performs mappings in the hundreds of gigabytes range.  But it probably
won't be too many years until that one happens.

But the basic point even at tens of gigabtyes is still valid.

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
