Date: Sat, 13 Mar 2004 13:48:42 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
Message-Id: <20040313134842.78695cc6.akpm@osdl.org>
In-Reply-To: <405379ED.A7D6B1E4@us.ibm.com>
References: <1079130684.2961.134.camel@localhost>
	<20040312233900.0d68711e.akpm@osdl.org>
	<405379ED.A7D6B1E4@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: badari <pbadari@us.ibm.com>
Cc: maryedie@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

badari <pbadari@us.ibm.com> wrote:
>
> Andrew,
> 
> We don't see any degradation with -mm trees with DSS workloads.
> Meredith mentioned that the workload is "cached". Not much
> IO activity. I wonder how it can be related to readahead ?

Well I don't know what "cached" means really.  That's a reoccurring problem
with these complex performance tests which some groups are running: lack of
the really detailed information which kernel developers can use, long
turnaround times in gathering followup information, even slow email
turnaround times.  It's been a bit frustrating from that point of view.

I read the dbt3-pgsql setup docs.  It looks pretty formidable.  For a
start, it provides waaaaaaaaaay too many options.  Sure, tell people how to
tweak things, but provide some simple, standardised setup with works
out-of-the-box.  Maybe it does, I don't know.



Anyway, if it means that the database is indeed in pagecache and this test
is not using direct-io then presumably there's a lot of synchronous write
traffic happening and not much reading?   A vmstat strace would tell.

And if that is indeed the case I'd be suspecting the CPU scheduler.  But
then, Meredith's profiles show almost completely idle CPUs.

The simplest way to hunt this down is the old binary-search-through-the-patches process.  But that requires some test which takes just a few minutes.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
