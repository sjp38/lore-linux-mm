Date: Tue, 13 Jul 2004 15:22:19 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040713222219.GL21066@holomorphy.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com> <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2004 at 09:41:34PM +0100, Hugh Dickins wrote:
> I think Jack's right: there's no visible mount point for df or du,
> the files come ready-unlinked, nobody has an fd.
> Though wli's per-cpu idea was sensible enough, converting to that
> didn't appeal to me very much.  We only have a limited amount of
> per-cpu space, I think, but an indefinite number of tmpfs mounts.
> Might be reasonable to allow per-cpu for 4 or them (the internal
> one which is troubling you, /dev/shm, /tmp and one other).  Tiresome.
> Jack's perception appeals to me much more
> (but, like you, I do wonder if it'll really work out in practice).

I ignored the specific usage case and looked only at the generic one.
Though I actually had in mind just shoving an array of cachelines in
the per-sb structure, it apparently is not even useful to maintain for
the case in question, so why bother?.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
