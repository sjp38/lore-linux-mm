Date: Wed, 4 Feb 2004 10:27:11 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 2/5] mm improvements
In-Reply-To: <20040204021035.2a6ca8a2.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0402041026400.24515-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Andrew Morton wrote:
> Nick Piggin <piggin@cyberone.com.au> wrote:
> >  > 2/5: vm-dont-rotate-active-list.patch
> >  >     Nikita's patch to keep more page ordering info in the active list.
> >  >     Also should improve system time due to less useless scanning
> >  >     Helps swapping loads significantly.
> 
> It bugs me that this improvement is also applicable to 2.4.  if it makes
> the same improvement there, we're still behind.

I suspect 2.4 won't see the gains from this, since active/inactive
list location is hardly relevant for mapped pages there, due to the
page table scanning algorithm.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
