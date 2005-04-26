Date: Mon, 25 Apr 2005 21:15:14 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 7/8 cluster pageout
Message-Id: <20050425211514.29e7c86b.akpm@osdl.org>
In-Reply-To: <16994.40699.267629.21475@gargle.gargle.HOWL>
References: <16994.40699.267629.21475@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Implement pageout clustering at the VM level.

I dunno...

Once __mpage_writepages() has started I/O against the pivot page, I don't
see that we have any guarantees that some other CPU cannot come in,
truncated or reclaim all the inode's pages and then reclaimed the inode
altogether.  While __mpage_writepages() is still dinking with it all.

I had something like this happening in 2.5.10(ish), but ended up deciding
it was all too complex and writeout from the LRU is rare and the pages are
probably close-by on the LRU and the elevator sorting would catch most
cases so I tossed it all out.

Plus some of your other patches make LRU-based writeout even less common.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
