Date: Thu, 21 Oct 2004 22:51:34 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
In-Reply-To: <20041022004159.GB14325@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0410212250500.13944-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: Andrew Morton <akpm@osdl.org>, shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2004, Andrea Arcangeli wrote:

> The pte shootdown from my point of view is just an additional coherency
> feature, but it cannot provide full coherency anyways, since the
> invalidate arrives after the I/O hit the disk, so the page will be out
> of sync with the disk if it's dirty, and no coherency can be provided
> anyways, because no locking happens to get max scalability.

That depends on the filesystem.  I hope the clustered filesystems
will be able to provide full coherency by doing the invalidates
in the right order.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
