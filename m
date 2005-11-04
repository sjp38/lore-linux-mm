Date: Thu, 3 Nov 2005 23:36:28 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] swapin rlimit
Message-Id: <20051103233628.12ed1eee.akpm@osdl.org>
In-Reply-To: <20051104072628.GA20108@elte.hu>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	<200511021747.45599.rob@landley.net>
	<43699573.4070301@yahoo.com.au>
	<200511030007.34285.rob@landley.net>
	<20051103163555.GA4174@ccure.user-mode-linux.org>
	<1131035000.24503.135.camel@localhost.localdomain>
	<20051103205202.4417acf4.akpm@osdl.org>
	<20051104072628.GA20108@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: pbadari@gmail.com, torvalds@osdl.org, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> wrote:
>
> * Andrew Morton <akpm@osdl.org> wrote:
> 
>  > Similarly, that SGI patch which was rejected 6-12 months ago to kill 
>  > off processes once they started swapping.  We thought that it could be 
>  > done from userspace, but we need a way for userspace to detect when a 
>  > task is being swapped on a per-task basis.
> 
>  wouldnt the clean solution here be a "swap ulimit"?

Well it's _a_ solution, but it's terribly specific.

How hard is it to read /proc/<pid>/nr_swapped_in_pages and if that's
non-zero, kill <pid>?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
