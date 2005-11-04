Date: Thu, 3 Nov 2005 23:45:30 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051103234530.5fcb2825.pj@sgi.com>
In-Reply-To: <20051103231019.488127a6.akpm@osdl.org>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	<200511021747.45599.rob@landley.net>
	<43699573.4070301@yahoo.com.au>
	<200511030007.34285.rob@landley.net>
	<20051103163555.GA4174@ccure.user-mode-linux.org>
	<1131035000.24503.135.camel@localhost.localdomain>
	<20051103205202.4417acf4.akpm@osdl.org>
	<20051103213538.7f037b3a.pj@sgi.com>
	<20051103214807.68a3063c.akpm@osdl.org>
	<20051103224239.7a9aee29.pj@sgi.com>
	<20051103231019.488127a6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: bron@bronze.corp.sgi.com, pbadari@gmail.com, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, mingo@elte.hu, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> >  So I will leave that challenge on the table for someone else.
> 
> And I won't merge your patch ;)

Be that way ;).


> Seriously, it does appear that doing it per-task is adequate for your
> needs, and it is certainly more general.

My motivations for the per-cpuset, digitally filtered rate, as opposed
to the per-task raw counter mostly have to do with minimizing total
cost (user + kernel) of collecting this information.  I have this phobia,
perhaps not well founded, that moving critical scheduling/allocation
decisions like this into user space will fail in some cases because
the cost of gathering the critical information will be too intrusive
on system performance and scalability.

A per-task stat requires walking the tasklist, to build a list of the
tasks to query.

A raw counter requires repeated polling to determine the recent rate of
activity.

The filtered per-cpuset rate avoids any need to repeatedly access
global resources such as the tasklist, and minimizes the total cpu
cycles required to get the interesting stat.


> But I have to care for all users.

Well you should, and well you do.

If you have good reason, or just good instincts, to think that there
are uses for per-task raw counters, then your choice is clear.

As indeed it was clear.

I don't recall hearing of any desire for per-task memory pressure data,
until tonight.

I will miss this patch.  It had provided exactly what I thought was
needed, with an extremely small impact on system (kern+user) performance.

Oh well.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
