Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEEDC282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:07:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6206221773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:07:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6206221773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB6D86B0005; Fri, 24 May 2019 06:07:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E688C6B0006; Fri, 24 May 2019 06:07:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2F7B6B0007; Fri, 24 May 2019 06:07:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C04E6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:07:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y12so13390050ede.19
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:07:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QqKpuj0mmYx+uCci2M+cHaGGxNiG98Iy/JNTS3kUzuY=;
        b=kTBIzR/4ydUEOpUxDMdeBGojyX0WAD6bxZQ2rpHU0g2oK5zlZgGyt7aki6jlCfPEdq
         TFidVXEUm9W+7h8ceGt81xc8lWcPIhnscREtH7O4UUk/Zz3MhpvU0py5tLBNcywLIpix
         XUF7JfqASh6nbPkCyZAt/VqDItaUj2lNIq1r/ukRscClXNsYtG5gHKGyUvyrmt9K4VJR
         pjSK0ooNsbsIMhT+q1jFKbkiDnOYJIy+cs2i+gFOQLPJZGu8c8/AFuVEWdkJ65uCacC8
         sKfzaSWD+IKRPn+9OZF/5wMCZ2/Oc6ZwYzTPn37PllS8+G+Fn7bAPsM9cXgPHsTbTtHI
         /LAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAU76/IumyWbhdWIQXiMUz3SvxQzcL6F6txay9Jd5hXd7ZM7oI4t
	/K+imWJfGabwgjii/vroadjOOGIMBIcCZDev7PVZnXmi6UR4jv6p/1o7lSGVRJXA/gxZ/1f1DpH
	HanHCS5tI7HIa16+6WQiWg1jT2Sq/Xh4yEqQUnN+0Aop1E7mL0GZ5+ReMXnhJX15+jg==
X-Received: by 2002:a17:906:19e:: with SMTP id 30mr2186465ejb.135.1558692428899;
        Fri, 24 May 2019 03:07:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbZXZmj6BjlvEu4ky/nOQZf926FShrB1cRPjT1DO3LkZR5kDdIUDub3Uf0E3f/wuj2LFlQ
X-Received: by 2002:a17:906:19e:: with SMTP id 30mr2186319ejb.135.1558692427007;
        Fri, 24 May 2019 03:07:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558692427; cv=none;
        d=google.com; s=arc-20160816;
        b=j8nkv3bQZuzxDcWMm+kLRfRUx66XacyH3xYeFJE+T/z7GW0SaQ1396j9Cd7im3PR6s
         YdSqdtZjRHvKCYqSltvo0T63ejOlq8xUBvyNhwD2XR1gT2aJMFRoWQL8o4aqh2Nd9JIi
         CCUJdXsDejk9e97NGltZ6RoH6o1oinj/lnJTbO3MboEXZwRUm8NahLa/7fwndvcBKBS5
         AQZDTjtzJIEmuNAWB1hq6NIg10UpWi8h0eY31FBwoUJbPvAI9iPhKQs6mlwVamPCsYFs
         41q+Fv0ZTsdAo0vgWIwT8e1kFa1Q5FwvXPqy8n1gPMonnhF5vAP9/aM+ySswyWUkyBJ/
         5QqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QqKpuj0mmYx+uCci2M+cHaGGxNiG98Iy/JNTS3kUzuY=;
        b=THgUffvXqNvTElacPwvRZX8WoLeTPknAUH3MMMlkBAWKyc0mtobGqErHTIovTCCqF6
         Q5CWzNqqeN2DyMA9h3PMrfe5COAk0+9QGNYUb74Z2/M5arChvUQuXSSYVO/042dKYefN
         CQD986uRJ4WFwBx0Gu7HHbiRUiPFKTbYpECzCyPRQKHiFUFnkOPMLUTonBZbsGuItr+3
         moiMuEBa9FmzKyRwaZpC/QFG+RZJuaNtNi4Ep5h6LKwRLpWbwJoqIPupG0/m1N2v7mLD
         TXzVSsEHGpVMmj7b5ovvLlbiK2MwT9x+x/kpwH47/ksaZpUhJhimVU05ziELeFiCyhno
         71HA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si1435141edb.189.2019.05.24.03.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 03:07:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 73300AF33;
	Fri, 24 May 2019 10:07:06 +0000 (UTC)
Date: Fri, 24 May 2019 11:07:02 +0100
From: Mel Gorman <mgorman@suse.de>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190524100702.GD23719@suse.de>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 10:54:16AM -0700, David Rientjes wrote:
> On Mon, 20 May 2019, Mel Gorman wrote:
> 
> > > There was exhausting discussion subsequent to this that caused Linus to 
> > > have to revert the offending commit late in an rc series that is not 
> > > described here. 
> > 
> > Yes, at the crux of that matter was which regression introduced was more
> > important -- the one causing swap storms which Andrea is trying to address
> > or a latency issue due to assumptions of locality when MADV_HUGEPAGE
> > is used.
> > 
> > More people are affected by swap storms and distributions are carrying
> > out-of-tree patches to address it. Furthermore, multiple people unrelated
> > to each other can trivially reproduce the problem with test cases and
> > experience the problem with real workloads. Only you has a realistic
> > workload sensitive to the latency issue and we've asked repeatedly for
> > a test case (most recently Michal Hocko on May 4th) which is still not
> > available.
> > 
> 
> Hi Mel,
> 
> Any workload that does MADV_HUGEPAGE will be impacted if remote hugepage 
> access latency is greater than local native page access latency and is 
> using the long-standing behavior of the past three years. 

And prior to that, THP usage could cause massive latencies due to reclaim
and compaction that was adjusted over time to cause the least harm. We've
had changes in behaviour for THP and madvise before -- largely due to cases
where THP allocation caused large stalls that users found surprising. These
stalls generated quite a substantial number of bugs in the field.

As before, what is important is causing the least harm to the most
people when corner cases are hit.

> The test case 
> would be rather straight forward: induce node local fragmentation (easiest 
> to do by injecting a kernel module), do MADV_HUGEPAGE over a large range, 
> fault, and measure random access latency.  This is readily observable and 
> can be done synthetically to measure the random access latency of local 
> native pages vs remote hugepages.  Andrea provided this testcase in the 
> original thread.  My results from right now:
> 
> # numactl -m 0 -C 0 ./numa-thp-bench
> random writes MADV_HUGEPAGE 17492771 usec
> random writes MADV_NOHUGEPAGE 21344846 usec
> random writes MADV_NOHUGEPAGE 21399545 usec
> random writes MADV_HUGEPAGE 17481949 usec
> # numactl -m 0 -C 64 ./numa-thp-bench
> random writes MADV_HUGEPAGE 26858061 usec
> random writes MADV_NOHUGEPAGE 31067825 usec
> random writes MADV_NOHUGEPAGE 31334770 usec
> random writes MADV_HUGEPAGE 26785942 usec
> 

Ok, lets consider two scenarios.

The first one is very basic -- using a large buffer that is larger than
a memory node size. The demonstation program is simple

--8<-- mmap-demo.c --8<--
#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LOOPS 3
#ifndef MADV_FLAGS
#define MADV_FLAGS 0
#endif

int main(int argc, char **argv)
{
	char *buf;
	int i;
	size_t length;

	if (argc != 2) {
		printf("Specify buffer size in bytes\n");
		exit(EXIT_FAILURE);
	}

	length = atol(argv[1]) & ~4095;
	buf = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
	if (buf == MAP_FAILED) {
		perror("mmap failed");
		exit(EXIT_FAILURE);
	}

	if (MADV_FLAGS)
		madvise(buf, length, MADV_FLAGS);

	printf("Address %p Length %lu MB\n", buf, length / 1048576);
	for (i = 0; i < LOOPS; i++) {
		memset(buf, i, length);
		printf(".");
		fflush(NULL);
	}
	printf("\n");
}
--8<-- mmap-demo.c --8<--

All it's doing is writing a large anonymous array. Lets see how it
behaves

# Set buffer size to 80% of memory -- machine has 2 nodes that are
# equal size so this will spill over
$ BUFSIZE=$((`free -b | grep Mem: | awk '{print $2}'`*8/10))

# Scenario 1: default setting, no madvise. Using CPUs from only one
# node as otherwise numa balancing or cpu balancing will migrate
# the task based on locality. Not particularly unusual when packing
# virtual machines in a box
$ gcc -O2 mmap-demo.c -o mmap-demo && numactl --cpunodebind 0 /usr/bin/time ./mmap-demo $BUFSIZE
Address 0x7fdc5b890000 Length 51236 MB
...
25.48user 30.19system 0:55.68elapsed 99%CPU (0avgtext+0avgdata 52467180maxresident)k
0inputs+0outputs (0major+15388156minor)pagefaults 0swaps

Total time is 55.68 seconds to execute, lots of minor faults for the
allocations (some may be NUMA balancing). vmstat for the time it was
running was as follows

procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0 65001004     32 279528    0    1     1     1    1    1  0  0 100  0  0
 1  0      0 48025796     32 279516    0    0     0     1  281   75  0  2 98  0  0
 1  0      0 30927108     32 279444    0    0     0     0  285   54  0  2 98  0  0
 1  0      0 22250504     32 279284    0    0     0     0  277   44  0  2 98  0  0
 1  0      0 13665116     32 279272    0    0     0     0  288   67  0  2 98  0  0
 1  0      0 12432096     32 279196    0    0     0     0  276   46  2  0 98  0  0
 1  0      0 12429580     32 279452    0    0     0   598  297   96  1  1 98  0  0
 1  0      0 12429604     32 279432    0    0     0     3  278   50  1  1 98  0  0
 1  0      0 12429856     32 279432    0    0     0     0  289   68  1  1 98  0  0
 1  0      0 12429864     32 279420    0    0     0     0  275   43  2  0 98  0  0
 1  0      0 12429936     32 279420    0    0     0     0  298   61  1  1 98  0  0
 1  0      0 12429944     32 279416    0    0     0     0  275   42  1  1 98  0  0

That's fairly straight-forward. Memory gets used, no particularly
unusual activity when the buffer is allocated and updated. Now, lets
use MADV_HUGEPAGE

$ gcc -DMADV_FLAGS=MADV_HUGEPAGE -O2 mmap-demo.c -o mmap-demo && numactl --cpunodebind 0 /usr/bin/time ./mmap-demo $BUFSIZE
Address 0x7fe8b947d000 Length 51236 MB
...
25.46user 33.12system 1:06.80elapsed 87%CPU (0avgtext+0avgdata 52467172maxresident)k
1932184inputs+0outputs (30197major+15103633minor)pagefaults 0swaps

Just 10 seconds more due to being a simple case with few loops but look
at the major faults, there are non-zero even though there was plenty of
memory. Lets look at vmstat

procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0 64997812     32 279380    0    1     1     1    1    1  0  0 100  0  0
 1  0      0 47230624     32 279392    0    0     0     1  286   74  0  2 98  0  0
 0  1 324104 32915756     32 233752    0 64786     3 64790  350  330  0  1 98  0  0
 1  0 1048572 31166652     32 223076   32 144950    32 144950  485 2117  0  1 99  1  0
 1  0 1048572 23839632     32 223076    0    0     0     0  277 5777  0  2 98  0  0
 1  0 1048572 16598116     32 223064    0    0     0     0  281 5714  0  2 98  0  0
 0  1 502444 12947660     32 223064 107547    0 107549     0 3840 16245  0  1 99  0  0
 1  0    944 12515736     32 224368 85670    0 85737   629 3219 11098  1  0 99  0  0
 1  0    944 12514224     32 224368    0    0     0     0  275   42  2  1 98  0  0
 1  0    944 12514228     32 224364    0    0     0     0  280   52  1  1 98  0  0
 1  0    944 12514228     32 224364    0    0     0     0  275   44  1  1 98  0  0
 1  0    944 12513712     32 224364    0    0     0     0  291   69  2  0 98  0  0
 1  0    944 12513964     32 224364    0    0     0     0  274   43  1  1 98  0  0
 1  1 216228 12643952     32 224132    0 43008     0 43008  747  130  1  1 98  0  0
 1  0   1188 65081364     32 224464   57  819    62   819  296  111  0  1 99  0  0

That is showing large amounts of swaps out and in. This demonstration
case could be made much worse but it's illustrative of what has been
observed -- __GFP_THISNODE is harmful to MADV_HUGEPAGE.

Now, contrast this with your example

o Induce node local fragmentation using a kernel module that must be
  developed. No description on whether this should be equivalent to
  anonymous memory, file-backed or pinned like it was slab objects.
  No statment on whether the module memory should be able to migrate
  like what compaction does.
o Measure random access latency -- requires specific application
  knowledge or detailed perf analysis
o Applicable to applications that are extremely latency sensitive only

My example can be demonstrated by a 1st year computer programmer with
minimal effort. It is also visible to anyone creating a KVM instance
that is larger than a NUMA node if the virtual machine is using enough
of its memory.

Your example requires implementation of a kernel module with much
guesswork as to what is a realistic means and then implement an
application that is latency sensitive.

The bottom line is that far more people with much less experience can
detect a swap storm and know its bad. Furthermore, if MADV_HUGEPAGE is
used by something like KVM, there isn't a workaround except for
disabling THP for the application which for KVM is a big penalty. Your
scenario of having a latency access penalty is harder to detect and
depends on the state of the system at the time the application executes.

Contrast that with the workarounds for your situation where the system
is fragmented. There are multiple choices

1. Enable zone reclaim mode for the initialisation phase
2. Memory bind the application to the target node
3. "Flush" memory before the application starts with with something like
   numactl --membind=0 memhog -r10 $HIGH_PERCENTAGE_OF_NODE_0

It's clumsy but it's workable in the short term.

> > > This isn't an argument in support of this patch, there is a difference 
> > > between (1) pages of the native page size being faulted first locally
> > > falling back remotely and (2) hugepages being faulted first locally and 
> > > falling back to native pages locally because it has better access latency 
> > > on most platforms for workloads that do not span multiple nodes.  Note 
> > > that the page allocator is unaware whether the workload spans multiple 
> > > nodes so it cannot make this distinction today, and that's what I'd prefer 
> > > to focus on rather than changing an overall policy for everybody.
> > > 
> > 
> > Overall, I think it would be ok to have behaviour whereby local THP is
> > allocated if cheaply, followed by base pages local followed by the remote
> > options. However, __GFP_THISNODE removes the possibility of allowing
> > remote fallback and instead causing a swap storm and swap storms are
> > trivial to generate on NUMA machine running a mainline kernel today.
> > 
> 
> Yes, this is hopefully what we can focus on and I hope we can make forward 
> progress with (1) extending mempolicies to allow specifying hugepage 
> specific policies, (2) the prctl(), (3) improving the feedback loop 
> between compaction and direct reclaim, and/or (4) resolving the overloaded 
> the conflicting meanings of 
> /sys/kernel/mm/transparent_hugepage/{enabled,defrag} and 
> MADV_HUGEPAGE/MADV_NOHUGEPAGE.
> 

3 should be partially done with the latest compaction series, it's unclear
how far it goes for your case because it cannot be trivially reproduced
outside of your test environment. I never got any report back on how it
affected your workload but for the trivial cases, it helped (modulo bugs
that had to be fixed for corner cases on zone boundary handling).

1, 2 and 4 are undefined at this point because it's unclear what sort of
policies would suit your given scenario and whether you would be even
willing to rebuild the applications. For everybody else it's a simple
"do not use __GFP_THISNODE for MADV_HUGEPAGE". In the last few months,
there also has been no evidence of what policies would suit you or
associated patches.

What you want is zone_reclaim_mode for huge pages but for whatever
reason, are unwilling to enable zone_reclaim_mode. However, it would
make some sense to extend it. The current definition is

This is value ORed together of
1       = Zone reclaim on
2       = Zone reclaim writes dirty pages out
4       = Zone reclaim swaps pages

An optional extra would be

8	= Zone reclaim on for THP applications for MADV_HUGEPAGE
	  mappings to require both THP where possible and local
	  memory

The default would be off. Your systems would need to or the 8 value

Would that be generally acceptable? It would give sensible default
behaviour for everyone and the option for those users that know for a
fact their application fits in a NUMA node *and* is latency sensitive to
remote accesses.

> The issue here is the overloaded nature of what MADV_HUGEPAGE means and 
> what the system-wide thp settings mean. 

MADV_HUGEPAGE is documented to mean "Enable Transparent Huge Pages (THP)
for pages in the range specified by addr  and  length". It says nothing
about locality. Locality decisions are set by policies, not madvise.
MPOL_BIND would be the obvious choice for strict locality but that is
not always necessary the best decision. It is unclear if a policy like
MPOL_CPU_LOCAL for both base and THP allocations would actually help
you because the semantics could be defined in multiple ways. Critically,
there is little information on what level of effort the kernel should do
to give local memory.

> It cannot possibly provide sane 
> behavior of all possible workloads given only two settings.  MADV_HUGEPAGE 
> itself has *four* meanings: (1) determine hugepage eligiblity when not 
> default, (2) try to do sychronous compaction/reclaim at fault, (3) 
> determine eligiblity of khugepaged, (4) control defrag settings based on 
> system-wide setting.  The patch here is adding a fifth: (5) prefer remote 
> allocation when local memory is fragmented.  None of this is sustainable.
> 

Given that locality and reclaim behaviour for *all* pages was specified
by zone_reclaim_mode, it could be extended to cover special casing of THP.

> Note that this patch is also preferring remote hugepage allocation *over* 
> local hugepages before trying memory compaction locally depending on the 
> setting of vm.zone_reclaim_mode so it is infringing on the long-standing 
> behavior of (2) as well.
> 

Again, extending zone_reclaim_mode would act as a band-aid until the
various policies can be defined and agreed upon. Once that API is set,
it will be with us for a while and right now, we have swap storms.

> In situations such as these, it is not surprising that there are issues 
> reported with any combination of flags or settings and patches get 
> proposed to are very workload dependent.  My suggestion has been to move 
> in a direction where this can be resolved such that userspace has a clean 
> and stable API and we can allow remote hugepage allocation for workloads 
> that specifically opt-in, but not incur 25.8% greater access latency for 
> using the behavior of the past 3+ years.
> 

You suggest moving in a some direction but have offered very little in
terms of reproducing your problematic scenario or defining exactly what
those policies should mean. For most people if they want memory to be
local, they use MPOL_BIND and call it a day. It's not clear what policy
you would define that gets translated into behaviour you find acceptable.

> Another point that has consistently been raised on LKML is the inability 
> to disable MADV_HUGEPAGE once set: i.e. if you set it for faulting your 
> workload, you are required to do MADV_NOHUGEPAGE to clear it and then are 
> explicitly asking that this memory is not backed by hugepages.
> 

I missed that one but it does not sound like an impossible problem to
define another MADV flag for it.

> > > It may not have been meant to provide this, but when IBM changed this 
> > > three years ago because of performance regressions and others have started 
> > > to use MADV_HUGEPAGE with that policy in mind, it is the reality of what 
> > > the madvise advice has provided.  What was meant to be semantics of 
> > > MADV_HUGEPAGE three years ago is irrelevant today if it introduces 
> > > performance regressions for users who have used the advice mode during 
> > > that past three years.
> > > 
> > 
> > Incurring swap storms when there is plenty of free memory available is
> > terrible. If the working set size is larger than a node, the swap storm
> > may even persist indefinitely.
> > 
> 
> Let's fix it.
> 

That's what Andrea's patch does -- fixes trivial swap storms. It
does require you use existing memory policies *or* temporarily
enable zone_reclaim_mode during initialisation to get the locality
you want. Alternatively, we extend zone_reclaim_mode to apply to
THP+MADV_HUGEPAGE. You could also carry a revert seeing as the kernel is
used for an internal workload where as some of us have to support all
classes of users running general workloads where causing the least harm
is important for supportability.

> > The current behaviour is potential swap storms that are difficult to
> > avoid because the behaviour is hard-wired into the kernel internals.
> > Only disabling THP, either on a task or global basis, avoids it when
> > encountered.
> > 
> 
> We are going in circles, *yes* there is a problem for potential swap 
> storms today because of the poor interaction between memory compaction and 
> directed reclaim but this is a result of a poor API that does not allow 
> userspace to specify that its workload really will span multiple sockets 
> so faulting remotely is the best course of action. 

Yes, we're going in circles. I find it amazing that you think leaving
users with trivial to reproduce swap storms is acceptable until some
unreproducible workload can be fixed with some undefined set of
unimplemented memory policies.

What we have right now is a concrete problem with a fix that is being
naked with a counter-proposal being "someone should implement the test case
for me then define/implement policies that suit that specific test case".

-- 
Mel Gorman
SUSE Labs

