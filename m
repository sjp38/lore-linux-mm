Date: Sun, 15 Dec 2002 17:09:22 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: freemaps
Message-ID: <20021216010922.GG2690@holomorphy.com>
References: <3DFBF26B.47C04A6@digeo.com> <Pine.LNX.4.44.0212150926130.1831-100000@localhost.localdomain> <3DFC455E.1FD92CBC@digeo.com> <20021216005103.GF2690@holomorphy.com> <3DFD266A.422CB70C@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DFD266A.422CB70C@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ingo Molnar <mingo@elte.hu>, "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Dec 15, 2002 at 01:03:26AM -0800, Andrew Morton wrote:
>>> - How does it play with non-linear mappings?

William Lee Irwin III wrote:
>> It doesn't care; they're just vma's parked on a virtual address range
>> like the rest of them.

On Sun, Dec 15, 2002 at 05:03:38PM -0800, Andrew Morton wrote:
> But the searching needs are different.  If someone has a nonlinear mmap
> of the 0-1M region of a file and then requests an mmap of the 4-5M region,
> that can just be tacked onto the 0-1M mapping's vma (can't it?).

Well, that's more of a merging criterion that a search criterion. At
any rate, while it's true that they can/could be merged arbitrarily
since they're not actually associated with any particular file offset
range, there isn't any indicator I know of now that would actually
allow this distinction wrt. mergeability to be made.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
