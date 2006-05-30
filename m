MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17532.630.796436.488394@wombat.chubb.wattle.id.au>
Date: Tue, 30 May 2006 18:29:42 +1000
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
In-Reply-To: <yq0irnot028.fsf@jaguar.mkp.net>
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
	<yq0irnot028.fsf@jaguar.mkp.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jes Sorensen <jes@sgi.com>
Cc: pauld@gelato.unsw.edu.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Jes" == Jes Sorensen <jes@sgi.com> writes:

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

Jes> Paul,

Jes> Let me just get it right as I am not sure I am reading it
Jes> correctly.  Are you saying that this patch causes a 3.5% fork
Jes> performance degradation on ia64 or are you saying it is improving
Jes> 3.5%?

I believe that yes, there is currently a small performance degradation
on IA64.  I think we'll get that back when we put a more appropriate
page table under the interface.  And this is the first cut, and can be
made more efficient anyway.

I'm not sure whether Paul's benchmarked yet on x86, but that's the
critical place where performance matters for this interface, because
x86 will use the same page table (under the interface) as at
present.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
