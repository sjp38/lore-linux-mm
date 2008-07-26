Date: Sat, 26 Jul 2008 15:04:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726130406.GA21820@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726113813.GD21150@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 01:38:13PM +0200, Andrea Arcangeli wrote:
> 
> 1) absolute minimal intrusion into the kernel common code, and
>    absolute minimum number of branches added to the kernel fast
>    paths. Kernel is faster than your "minimal" type of notifiers when
>    they're disarmed.

BTW. is this really significant? Having one branch per pte
I don't think is necessarily slower than 2 branches per unmap.

The 2 branches will use more icache and more branch history. One
branch even once per pte in the unmapping loop is going to remain
hot in icache and branch history isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
