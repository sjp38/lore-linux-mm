Subject: Re: [patch] swapin rlimit
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20051103233628.12ed1eee.akpm@osdl.org>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	 <200511021747.45599.rob@landley.net> <43699573.4070301@yahoo.com.au>
	 <200511030007.34285.rob@landley.net>
	 <20051103163555.GA4174@ccure.user-mode-linux.org>
	 <1131035000.24503.135.camel@localhost.localdomain>
	 <20051103205202.4417acf4.akpm@osdl.org> <20051104072628.GA20108@elte.hu>
	 <20051103233628.12ed1eee.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 04 Nov 2005 09:18:42 +0100
Message-Id: <1131092322.2799.3.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ingo Molnar <mingo@elte.hu>, pbadari@gmail.com, torvalds@osdl.org, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-03 at 23:36 -0800, Andrew Morton wrote:
> Ingo Molnar <mingo@elte.hu> wrote:
> >
> > * Andrew Morton <akpm@osdl.org> wrote:
> > 
> >  > Similarly, that SGI patch which was rejected 6-12 months ago to kill 
> >  > off processes once they started swapping.  We thought that it could be 
> >  > done from userspace, but we need a way for userspace to detect when a 
> >  > task is being swapped on a per-task basis.
> > 
> >  wouldnt the clean solution here be a "swap ulimit"?
> 
> Well it's _a_ solution, but it's terribly specific.
> 
> How hard is it to read /proc/<pid>/nr_swapped_in_pages and if that's
> non-zero, kill <pid>?

well or do it the other way around

write a counter to such a thing
and kill when it hits zero
(similar to the CPU perf counter stuff on x86)

doing this from userspace is tricky; what if the task dies of natural
causes and the pid gets reused, between the time the userspace app reads
the value and the time it decides the time is up and time for a kill....
(and on a busy server that can be quite a bit of time)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
