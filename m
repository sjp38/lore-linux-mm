Date: Fri, 28 May 2004 22:08:55 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: Re: mmap() > phys mem problem
In-Reply-To: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com>
Message-ID: <Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com>
References: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ron Maeder <rlm@orionmulti.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2004, Ron Maeder wrote:

> Is this an "undocumented feature" or is this a linux error?  I would
> expect pages of the mmap()'d file would get paged back to the original
> file. I know this won't be fast, but the performance is not an issue for
> this application.

It looks like a kernel bug.  Can you reproduce this problem
with the latest 2.6 kernel or is it still there ?

Rik
-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
