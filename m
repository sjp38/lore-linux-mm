Date: Thu, 29 Aug 2002 19:52:18 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: weirdness with ->mm vs ->active_mm handling
Message-ID: <20020829195218.I17288@redhat.com>
References: <20020829193413.H17288@redhat.com> <Pine.GSO.4.21.0208291940350.15425-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.21.0208291940350.15425-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Thu, Aug 29, 2002 at 07:45:49PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2002 at 07:45:49PM -0400, Alexander Viro wrote:
> Lazy-TLB == "promise not to use a lot of stuff in the kernel".  In particular,
> any page fault in that state is a bug.

In that case the lazy vmalloc faulting code is busted, as accessing a vmalloc 
page may need to fill in a pgd/pmd entry from a lazy tlb task.  Got an idea 
for a more preferable fix?

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
