Date: Wed, 28 Jul 2004 16:05:37 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-Id: <20040728160537.57c8c85b.akpm@osdl.org>
In-Reply-To: <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
	<Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
	<20040728022625.249c78da.akpm@osdl.org>
	<20040728095925.GQ2334@holomorphy.com>
	<Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: wli@holomorphy.com, hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Brent Casavant <bcasavan@sgi.com> wrote:
>
> Now I'm running up against the shmem_inode_info
> lock field.

Normally a per-inode lock doesn't hurt too much because it's rare
for lots of tasks to whack on the same inode at the same time.

I guess with tmpfs-backed-shm, we have a rare workload.  How
unpleasant.

> I'm kind of hoping for a fairy godmother to drop in, wave her magic wand,
> and say "Here's the quick and easy and obviously correct solution".  But
> what're the chances of that :).

Oh, sending email to Hugh is one of my favourite problem-solving techniques.
Grab a beer and sit back.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
