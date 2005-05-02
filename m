Date: Sun, 1 May 2005 21:12:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH]: VM 7/8 cluster pageout
Message-ID: <20050502041257.GL2104@holomorphy.com>
References: <16994.40699.267629.21475@gargle.gargle.HOWL> <20050425211514.29e7c86b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050425211514.29e7c86b.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>> Implement pageout clustering at the VM level.

On Mon, Apr 25, 2005 at 09:15:14PM -0700, Andrew Morton wrote:
> I had something like this happening in 2.5.10(ish), but ended up deciding
> it was all too complex and writeout from the LRU is rare and the pages are
> probably close-by on the LRU and the elevator sorting would catch most
> cases so I tossed it all out.
> Plus some of your other patches make LRU-based writeout even less common.

Sorry for chiming in late on this issue.

I would be careful in dismissing the case as "rare"; what I've
discovered in this kind of performance scenario is that the rare case
happens to someone, who is willing to tolerate poor performance and
understands they're not the common case, but discovers pathological
performance instead and cries out for help (unfortunately, this is all
subjective). I'd be glad to see some bulletproofing of the VM against
this case go into mainline, not to specifically recommend this approach
against any other.

By and large I've seen writeout from the LRU get dismissed and I'm
convinced that although it should be rare, some (moderate?) steps
are in order to ensure the degradation from such is not too severe
(though poor performance is can be tolerated, pathological can't).


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
