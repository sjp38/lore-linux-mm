Date: Fri, 14 Sep 2007 07:59:43 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 1/1] cpusets/sched_domain reconciliation
Message-ID: <20070913225942.GA2384@linux-sh.org>
References: <20070907210704.E6BE02FC059@attica.americas.sgi.com> <20070913154607.9c49e1c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070913154607.9c49e1c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cliff Wickman <cpw@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Paul Jackson <pj@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 13, 2007 at 03:46:07PM -0700, Andrew Morton wrote:
> On Fri, 07 Sep 2007 16:07:04 -0500
> cpw@sgi.com (Cliff Wickman) wrote:
> > Thus the patch to cpuset.c makes the sched_domain's correct.
> 
> You should cc scheduler gurus when hoping things about them ;)
> 
> I suspect your change is fundamentally incompatible with, and perhaps
> obsoleted by
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/broken-out/cpuset-remove-sched-domain-hooks-from-cpusets.patch
> 
> Problem is, cpuset-remove-sched-domain-hooks-from-cpusets.patch has been
> hanging around in -mm for a year while Paul makes up his mind about it.
> 
> Can we please get all this sorted out??
> 
Note that removing the scheduler domain hooks also fixes up the build for
cpusets on UP NUMA. If this patch isn't going to go in, the other
alternative is simply to stub out scheduler domains there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
