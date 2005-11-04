Date: Thu, 3 Nov 2005 20:52:02 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051103205202.4417acf4.akpm@osdl.org>
In-Reply-To: <1131035000.24503.135.camel@localhost.localdomain>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	<200511021747.45599.rob@landley.net>
	<43699573.4070301@yahoo.com.au>
	<200511030007.34285.rob@landley.net>
	<20051103163555.GA4174@ccure.user-mode-linux.org>
	<1131035000.24503.135.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, mingo@elte.hu, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@gmail.com> wrote:
>
>  > With Badari's patch and UML memory hotplug, the infrastructure is
>  > there to make this work.  The one thing I'm puzzling over right now is
>  > how to measure memory pressure.
> 
>  Yep. This is the exactly the issue other product groups normally raise
>  on Linux. How do we measure memory pressure in linux ? Some of our
>  software products want to grow or shrink their memory usage depending
>  on the memory pressure in the system. Since most memory is used for
>  cache, "free" really doesn't indicate anything -they are monitoring
>  info in /proc/meminfo and swapping rates to "guess" on the memory
>  pressure. They want a clear way of finding out "how badly" system
>  is under memory pressure. (As a starting point, they want to find out
>  out of "cached" memory - how much is really easily "reclaimable" 
>  under memory pressure - without swapping). I know this is kind of 
>  crazy, but interesting to think about :)

Similarly, that SGI patch which was rejected 6-12 months ago to kill off
processes once they started swapping.  We thought that it could be done
from userspace, but we need a way for userspace to detect when a task is
being swapped on a per-task basis.

I'm thinking a few numbers in the mm_struct, incremented in the pageout
code, reported via /proc/stat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
