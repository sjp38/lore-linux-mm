Date: Fri, 30 Jul 2004 16:40:22 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407301633051.36748@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2004, Hugh Dickins wrote:

> Why doesn't the creator of the shm segment or /dev/zero mapping just
> fault in all the pages before handing over to the other threads?

Dean Roe pointed out another answer to this.  For NUMA locality reasons
you want individual physical pages to be near the CPU which will use it
most heavily.  Having a single CPU fault in all the pages will generally
cause all pages to reside on a single NUMA node.

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
