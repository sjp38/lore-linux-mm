Date: Mon, 2 May 2005 01:51:27 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH]: VM 7/8 cluster pageout
In-Reply-To: <20050502041257.GL2104@holomorphy.com>
Message-ID: <Pine.LNX.4.61.0505020148470.1371@chimarrao.boston.redhat.com>
References: <16994.40699.267629.21475@gargle.gargle.HOWL>
 <20050425211514.29e7c86b.akpm@osdl.org> <20050502041257.GL2104@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, Nikita Danilov <nikita@clusterfs.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 1 May 2005, William Lee Irwin III wrote:

> I would be careful in dismissing the case as "rare"; what I've
> discovered in this kind of performance scenario is that the rare case
> happens to someone, who is willing to tolerate poor performance and
> understands they're not the common case, but discovers pathological
> performance instead and cries out for help (unfortunately, this is all
> subjective). I'd be glad to see some bulletproofing of the VM against
> this case go into mainline, not to specifically recommend this approach
> against any other.

Agreed.  The VM is all about preventing these "corner cases",
because there will always be users who run into them the whole
time - from bootup till shutdown - and we can't degenerate to
pathological performance for somebody's main workload ;)

Of course, if there isn't an actual workload that's being
improved by some patch we should avoid the complexity, but
if a patch helps enough to outweigh its complexity ...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
