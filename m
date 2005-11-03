From: Rob Landley <rob@landley.net>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Thu, 3 Nov 2005 12:49:27 -0600
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com> <20051103163555.GA4174@ccure.user-mode-linux.org> <1131035000.24503.135.camel@localhost.localdomain>
In-Reply-To: <1131035000.24503.135.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511031249.28072.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Jeff Dike <jdike@addtoit.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Gerrit Huizenga <gh@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thursday 03 November 2005 10:23, Badari Pulavarty wrote:

> Yep. This is the exactly the issue other product groups normally raise
> on Linux. How do we measure memory pressure in linux ? Some of our
> software products want to grow or shrink their memory usage depending
> on the memory pressure in the system. Since most memory is used for
> cache, "free" really doesn't indicate anything -they are monitoring
> info in /proc/meminfo and swapping rates to "guess" on the memory
> pressure. They want a clear way of finding out "how badly" system
> is under memory pressure. (As a starting point, they want to find out
> out of "cached" memory - how much is really easily "reclaimable"
> under memory pressure - without swapping). I know this is kind of
> crazy, but interesting to think about :)

If we do ever get prezeroing, we'd want a tuneable to say how much memory 
should be spent on random page cache and how much should be prezeroed.  And 
large chunks of prezeroed memory lying around are what you'd think about 
handing back to the host OS...

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
