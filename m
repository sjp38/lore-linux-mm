Date: Wed, 4 Feb 2004 10:28:35 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 3/5] mm improvements
In-Reply-To: <4020BE45.10007@cyberone.com.au>
Message-ID: <Pine.LNX.4.44.0402041027380.24515-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.44.0402041027382.24515@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Nick Piggin wrote:
> Nick Piggin wrote:
> 
> > 3/5: vm-lru-info.patch
> >     Keep more referenced info in the active list. Should also improve
> >     system time in some cases. Helps swapping loads significantly.

I suspect this is one of the more important ones in this
batch of patches...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
