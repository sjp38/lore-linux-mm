Date: Tue, 22 Apr 2003 07:32:36 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <171070000.1051021955@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.44.0304220618190.24063-100000@devserv.devel.redhat.com>
References: <Pine.LNX.4.44.0304220618190.24063-100000@devserv.devel.redhat.c
 om>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>
Cc: Andrea Arcangeli <andrea@suse.de>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It also makes it easy to calculate the overhead of the pte chains: twice
> the amount of pagetable overhead. Ie. with 32-bit pte's it's +8 bytes
> overhead, or +0.2% of RAM overhead per mapped page, using a 4K page. With
> 64-bit ptes on 32-bit platforms (PAE), the overhead is still 8 bytes. On
> 64-bit platforms using 8K pages the overhead is still +0.2% of RAM, in
> additionl to the 0.1% of RAM overhead for the pte itself. The worst-case
> is 64-bit platforms with a 4K pagesize, there the overhead is +0.4% of
> RAM, in addition to the 0.2% overhead caused by the pte itself.

Oh, BTW. You're assuming no sharing of any pages in the above. Look what
happens if 1000 processes share the same page ... 

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
