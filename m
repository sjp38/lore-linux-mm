Date: Wed, 28 Jul 2004 02:59:25 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040728095925.GQ2334@holomorphy.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com> <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain> <20040728022625.249c78da.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040728022625.249c78da.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, bcasavan@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>> Though wli's per-cpu idea was sensible enough, converting to that
>>  didn't appeal to me very much.  We only have a limited amount of
>>  per-cpu space, I think, but an indefinite number of tmpfs mounts.

On Wed, Jul 28, 2004 at 02:26:25AM -0700, Andrew Morton wrote:
> What's wrong with <linux/percpu_counter.h>?

One issue with using it for the specific cases in question is that the
maintenance of the statistics is entirely unnecessary for them.

For the general case it may still make sense to do this. SGI will have
to comment here, as the workloads I'm involved with are kernel intensive
enough in other areas and generally run on small enough systems to have
no visible issues in or around the areas described.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
