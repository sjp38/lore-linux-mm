Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
From: Jes Sorensen <jes@sgi.com>
Date: 30 May 2006 03:59:43 -0400
In-Reply-To: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <yq0irnot028.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Paul" == Paul Cameron Davies <pauld@cse.unsw.EDU.AU> writes:

Paul> This patch series provides the architectural independent
Paul> interface.  It has been tested and benchmarked for IA64 using
Paul> lmbench.  It also passes all relevant tests in the Linux Test
Paul> Project (LTP) on IA64.  This patch should 5~also compile and run
Paul> for i386.  To run on other architectures add CONFIG_DEFAULT_PT
Paul> to the architectures config.  Turn off HugeTLB.

Paul> Summary of performance degradation using lmbench on IA64: ~3.5%
Paul> deterioration in fork latency on IA64.  ~1.0% deterioration in
Paul> mmap latency on IA64

Paul,

Let me just get it right as I am not sure I am reading it correctly.
Are you saying that this patch causes a 3.5% fork performance
degradation on ia64 or are you saying it is improving 3.5%?

Thanks,
Jes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
