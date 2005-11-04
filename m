Date: Thu, 3 Nov 2005 21:48:07 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051103214807.68a3063c.akpm@osdl.org>
In-Reply-To: <20051103213538.7f037b3a.pj@sgi.com>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	<200511021747.45599.rob@landley.net>
	<43699573.4070301@yahoo.com.au>
	<200511030007.34285.rob@landley.net>
	<20051103163555.GA4174@ccure.user-mode-linux.org>
	<1131035000.24503.135.camel@localhost.localdomain>
	<20051103205202.4417acf4.akpm@osdl.org>
	<20051103213538.7f037b3a.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, Bron Nelson <bron@bronze.corp.sgi.com>
Cc: pbadari@gmail.com, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, mingo@elte.hu, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> wrote:
>
> > Similarly, that SGI patch which was rejected 6-12 months ago to kill off
> > processes once they started swapping.  We thought that it could be done
> > from userspace, but we need a way for userspace to detect when a task is
> > being swapped on a per-task basis.
> > 
> > I'm thinking a few numbers in the mm_struct, incremented in the pageout
> > code, reported via /proc/stat.
> 
> I just sent in a proposed patch for this - one more per-cpuset
> number, tracking the recent rate of calls into the synchronous
> (direct) page reclaim by tasks in the cpuset.
> 
> See the message sent a few minutes ago, with subject:
> 
>   [PATCH 5/5] cpuset: memory reclaim rate meter
> 

uh, OK.  If that patch is merged, does that make Bron happy, so I don't
have to reply to his plaintive email?

I was kind of thinking that the stats should be per-process (actually
per-mm) rather than bound to cpusets.  /proc/<pid>/pageout-stats or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
