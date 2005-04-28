Date: Thu, 28 Apr 2005 07:56:07 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
In-Reply-To: <20050427233335.492d0b6f.akpm@osdl.org>
Message-ID: <Pine.LNX.4.61.0504280755170.32328@chimarrao.boston.redhat.com>
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Martin Hicks <mort@sgi.com>, linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 27 Apr 2005, Andrew Morton wrote:

> Is it not possible to change the page allocator's zone fallback mechanism
> so that once the local node's zones' pages are all allocated, we don't
> simply advance onto the next node?  Instead, could we not perform a bit of
> reclaim on this node's zones first?  Only advance onto the next nodes if
> things aren't working out?

IMHO that's the best idea.  The patches posted add new
mechanisms to the VM and have the potential to disturb
LRU ordering quite a bit - which could make the VM
worse under load.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
