Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: shared pagetable benchmarking
Date: Sat, 28 Dec 2002 00:56:40 +0100
References: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com>
In-Reply-To: <Pine.LNX.4.44.0212271244390.771-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E18S4LJ-0001uu-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Dave McCracken <dmccr@us.ibm.com>, Wim Coekaerts <wim.coekaerts@oracle.com>
Cc: Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 27 December 2002 21:50, Linus Torvalds wrote:
> On Fri, 27 Dec 2002, Dave McCracken wrote:
> > The other thing it does is eliminate the duplicate pte pages for shared
> > regions everywhere they span a complete pte page.  While hugetlb can also
> > do this for some specialized applications, shared page tables will do it
> > for every shared region that's large enough.  I dunno whether you
> > consider that important enough to qualify, but I figured I should point
> > it out.
>
> I don't consider it important enough to qualify unless there are some real
> loads where it really matters.

Well, I know IBM has real loads that it matters on, otherwise Dave wouldn't 
be on this.  I have reason to believe Oracle has loads that care about this 
as well, so it's time for somebody there to either speak up or kiss this 
facility goodbye for another cycle or two.  Wim?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
