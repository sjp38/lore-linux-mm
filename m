Date: Wed, 28 Jul 2004 02:26:25 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-Id: <20040728022625.249c78da.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
	<Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: bcasavan@sgi.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> Though wli's per-cpu idea was sensible enough, converting to that
>  didn't appeal to me very much.  We only have a limited amount of
>  per-cpu space, I think, but an indefinite number of tmpfs mounts.

What's wrong with <linux/percpu_counter.h>?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
