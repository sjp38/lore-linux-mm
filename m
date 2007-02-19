In-reply-to: <E1HIwLJ-0005N4-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Mon, 19 Feb 2007 01:25:21 +0100)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org> <E1HIwLJ-0005N4-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1HIweQ-0005RQ-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 19 Feb 2007 01:45:06 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > If so, writes to B will decrease the dirty memory threshold.
> > > 
> > > Yes, but not by enough.  Say A dirties a 1100 pages, limit is 1000.
> > > Some pages queued for writeback (doesn't matter how much).  B writes
> > > back 1, 1099 dirty remain in A, zero in B.  balance_dirty_pages() for
> > > B doesn't know that there's nothing more to write back for B, it's
> > > just waiting there for those 1099, which'll never get written.
> > 
> > hm, OK, arguable.  I guess something like this..
> 
> Doesn't help the fuse case, but does seem to help the loopback mount
> one.

No sorry, it doesn't even help the loopback deadlock.  It sometimes
takes quite a while to trigger...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
