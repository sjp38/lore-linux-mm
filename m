Date: Fri, 27 Dec 2002 14:45:53 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <58520000.1041021953@[10.1.1.5]>
In-Reply-To: <Pine.LNX.4.44.0212271213180.21930-100000@home.transmeta.com>
References: <Pine.LNX.4.44.0212271213180.21930-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, December 27, 2002 12:18:23 -0800 Linus Torvalds
<torvalds@transmeta.com> wrote:

> That's clearly not 2.6.x material. But at this point I doubt that shared
> page tables are either, unless they fix something more important than 
> fork() speed for processes that are larger than 16MB.

The other thing it does is eliminate the duplicate pte pages for shared
regions everywhere they span a complete pte page.  While hugetlb can also
do this for some specialized applications, shared page tables will do it
for every shared region that's large enough.  I dunno whether you consider
that important enough to qualify, but I figured I should point it out.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
