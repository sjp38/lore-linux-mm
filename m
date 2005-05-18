Date: Wed, 18 May 2005 17:16:14 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] prevent NULL mmap in topdown model
In-Reply-To: <1116448683.6572.43.camel@laptopd505.fenrus.org>
Message-ID: <Pine.LNX.4.61.0505181714330.3645@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
 <1116448683.6572.43.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 May 2005, Arjan van de Ven wrote:
> On Wed, 2005-05-18 at 15:57 -0400, Rik van Riel wrote:
> > This (trivial) patch prevents the topdown allocator from allocating
> > mmap areas all the way down to address zero.  It's not the prettiest
> > patch, so suggestions for improvement are welcome ;)
> 
> it looks like you stop at brk() time.. isn't it better to just stop just 
> above NULL instead?? Gives you more space and is less of an artificial 
> barrier..

Firstly, there isn't much below brk() at all.  Secondly, do we
really want to fill the randomized hole between the executable
and the brk area with data ?

Thirdly, we do want to continue detecting NULL pointer dereferences
inside large structs, ie. dereferencing an element 700kB into some
large struct...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
