Date: Fri, 8 Oct 2004 15:22:35 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: hit/miss
In-Reply-To: <20041008173155.52028.qmail@web52901.mail.yahoo.com>
Message-ID: <Pine.LNX.4.44.0410081522100.11449-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ankit Jain <ankitjain1580@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Oct 2004, Ankit Jain wrote:

> Consider a two-level memory hierarchy system M1 & M2.
> M1 is accessed first and on miss M2 is accessed. The
> access of M1 is 2 nanoseconds and the miss penalty
> (the time to get the data from M2 in case of a miss)
> is 100 nanoseconds. The probability that a valid data
> is found in M1 is 0.97. The average memory access time
> will be how much?
> 
> if somebody can solve this?

If you cannot solve this yourself, you might want to
complain to your teacher for not telling you how to
do your homework ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
