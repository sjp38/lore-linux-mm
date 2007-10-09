Date: Tue, 9 Oct 2007 14:00:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <200710090117.47610.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710091350090.17543@blonde.wat.veritas.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <200710030345.10026.nickpiggin@yahoo.com.au>
 <alpine.LFD.0.999.0710030813090.3579@woody.linux-foundation.org>
 <200710090117.47610.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Oct 2007, Nick Piggin wrote:
> 
> The commit b5810039a54e5babf428e9a1e89fc1940fabff11 contains the note
> 
>   A last caveat: the ZERO_PAGE is now refcounted and managed with rmap
>   (and thus mapcounted and count towards shared rss).  These writes to
>   the struct page could cause excessive cacheline bouncing on big
>   systems.  There are a number of ways this could be addressed if it is
>   an issue.
> 
> And indeed this cacheline bouncing has shown up on large SGI systems.
> There was a situation where an Altix system was essentially livelocked
> tearing down ZERO_PAGE pagetables when an HPC app aborted during startup.
> This situation can be avoided in userspace, but it does highlight the
> potential scalability problem with refcounting ZERO_PAGE, and corner
> cases where it can really hurt (we don't want the system to livelock!).
> 
> There are several broad ways to fix this problem:
> 1. add back some special casing to avoid refcounting ZERO_PAGE
> 2. per-node or per-cpu ZERO_PAGES
> 3. remove the ZERO_PAGE completely
> 
> I will argue for 3. The others should also fix the problem, but they
> result in more complex code than does 3, with little or no real benefit
> that I can see. Why?

Sorry, I've no useful arguments to add (and my testing was too much
like yours to add any value), but I do want to go on record as still
a strong supporter of approach 3 and your patch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
