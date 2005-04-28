Date: Thu, 28 Apr 2005 08:53:33 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-ID: <20050428125333.GG19244@localhost>
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org> <Pine.LNX.4.61.0504280755170.32328@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0504280755170.32328@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, Apr 28, 2005 at 07:56:07AM -0400, Rik van Riel wrote:
> On Wed, 27 Apr 2005, Andrew Morton wrote:
> 
> > Is it not possible to change the page allocator's zone fallback mechanism
> > so that once the local node's zones' pages are all allocated, we don't
> > simply advance onto the next node?  Instead, could we not perform a bit of
> > reclaim on this node's zones first?  Only advance onto the next nodes if
> > things aren't working out?
> 
> IMHO that's the best idea.  The patches posted add new
> mechanisms to the VM and have the potential to disturb
> LRU ordering quite a bit - which could make the VM
> worse under load.

I'd like to see Nick's patch.  Through the mempolicy the patch does take
the approach of freeing memory on the preferred node before going
offnode.  I agree that the patch disturbs LRU ordering.  The reason that
I have to destroy LRU ordering is so that I don't have to scan through
the same Dirty/Locked/whatever pages on the tail of the LRU list during
each call to reclaim_clean_pages().

mh

--
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
