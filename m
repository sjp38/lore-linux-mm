Date: Fri, 04 Nov 2005 07:24:04 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [patch] swapin rlimit
Message-ID: <325850000.1131117844@[10.10.2.4]>
In-Reply-To: <20051104080731.GB21321@elte.hu>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com> <200511021747.45599.rob@landley.net> <43699573.4070301@yahoo.com.au> <200511030007.34285.rob@landley.net> <20051103163555.GA4174@ccure.user-mode-linux.org> <1131035000.24503.135.camel@localhost.localdomain> <20051103205202.4417acf4.akpm@osdl.org> <20051104072628.GA20108@elte.hu> <20051103233628.12ed1eee.akpm@osdl.org> <20051104080731.GB21321@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>
Cc: pbadari@gmail.com, torvalds@osdl.org, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> System instrumentation people are already complaining about how costly 
> /proc parsing is. If you have to get some nontrivial stat from all 
> threads in the system, and if Linux doesnt offer that counter or summary 
> by default, it gets pretty expensive.
> 
> One solution i can think of would be to make a binary representation of 
> /proc/<pid>/stats readonly-mmap-able. This would add a 4K page to every 
> task tracked that way, and stats updates would have to update this page 
> too - but it would make instrumentation of running apps really 
> unintrusive and scalable.

That would be awesome - the current methods we have are mostly crap. There
are some atomicity issues though. Plus when I suggested this 2 years ago,
everyone told me to piss off, but I'm not bitter ;-) Seriously, we do
need a fast communication mechanism.
 
M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
