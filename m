Date: Fri, 27 Dec 2002 12:50:25 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: shared pagetable benchmarking
In-Reply-To: <58520000.1041021953@[10.1.1.5]>
Message-ID: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Dec 2002, Dave McCracken wrote:
>
> The other thing it does is eliminate the duplicate pte pages for shared
> regions everywhere they span a complete pte page.  While hugetlb can also
> do this for some specialized applications, shared page tables will do it
> for every shared region that's large enough.  I dunno whether you consider
> that important enough to qualify, but I figured I should point it out.

I don't consider it important enough to qualify unless there are some real 
loads where it really matters. I can well imagine that such loads exist 
(where low-memory usage by page tables is a real problem), but I'd like to 
have that confirmed as a bug-report and that the sharing really does fix 
it.

In other words, I can believe that the sharing is 2.6.x material, but
considering the fundamental nature of it I want it to be a confirmed
bug-fix, not a feature.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
