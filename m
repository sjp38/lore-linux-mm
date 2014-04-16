From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 17/19] VFS: set PF_FSTRANS while namespace_sem is held.
Date: Wed, 16 Apr 2014 17:37:41 +0100
Message-ID: <20140416163741.GY18016@ZenIV.linux.org.uk>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.86740.stgit@notabene.brown>
 <20140416044618.GX18016@ZenIV.linux.org.uk>
 <20140416155230.4d02e4b9@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140416155230.4d02e4b9-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
List-Id: linux-mm.kvack.org

On Wed, Apr 16, 2014 at 03:52:30PM +1000, NeilBrown wrote:

> So something like this?  I put that in to my testing instead.

Something like this, yes...  And TBH I would prefer the same approach
elsewhere - this kind of hidden state makes it hard to do any kind of
analysis.

Put it that way - the simplest situation is when the allocation flags
depend only on the call site.  Next one is when it's a function of
call chain - somewhat harder to review.  And the worst is when it's
a function of previous history of execution - not just the call chain,
but the things that had been called (and returned) prior to that one.

How many of those locations need to be of the third kind?  All fs/namespace.c
ones are of the first one...
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
