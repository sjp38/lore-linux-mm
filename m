Date: Wed, 18 May 2005 22:25:25 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] prevent NULL mmap in topdown model
In-Reply-To: <Pine.LNX.4.58.0505181535210.18337@ppc970.osdl.org>
Message-ID: <Pine.LNX.4.61.0505182224250.29123@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
 <Pine.LNX.4.58.0505181535210.18337@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 May 2005, Linus Torvalds wrote:

> Why not just change the "addr >= len" test into "addr > len" and be done 
> with it?

If you're fine with not catching dereferences of a struct
member further than PAGE_SIZE into a struct when the struct
pointer is NULL, sure ...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
