Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 3B31C6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 12:58:17 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <svaidy@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 22:28:13 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62GvdTQ9044224
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 22:27:40 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q62MQurU016673
	for <linux-mm@kvack.org>; Tue, 3 Jul 2012 08:26:57 +1000
Date: Mon, 2 Jul 2012 22:27:15 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120702165714.GA10952@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1340888180-15355-14-git-send-email-aarcange@redhat.com>
 <1340895238.28750.49.camel@twins>
 <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
 <20120629125517.GD32637@gmail.com>
 <4FEDDD0C.60609@redhat.com>
 <1340995260.28750.103.camel@twins>
 <4FEDF81C.1010401@redhat.com>
 <1340996224.28750.116.camel@twins>
 <1340996586.28750.122.camel@twins>
 <4FEDFFB5.3010401@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4FEDFFB5.3010401@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

* Rik van Riel <riel@redhat.com> [2012-06-29 15:19:17]:

> On 06/29/2012 03:03 PM, Peter Zijlstra wrote:
> >On Fri, 2012-06-29 at 20:57 +0200, Peter Zijlstra wrote:
> >>On Fri, 2012-06-29 at 14:46 -0400, Rik van Riel wrote:
> >>>
> >>>I am not convinced all architectures that have CONFIG_NUMA
> >>>need to be a requirement, since some of them (eg. Alpha)
> >>>seem to be lacking a maintainer nowadays.
> >>
> >>Still, this NUMA balancing stuff is not a small tweak to load-balancing.
> >>Its a very significant change is how you schedule. Having such great
> >>differences over architectures isn't something I look forward to.
> 
> I am not too worried about the performance of architectures
> that are essentially orphaned :)
> 
> >Also, Andrea keeps insisting arch support is trivial, so I don't see the
> >problem.
> 
> Getting it implemented in one or two additional architectures
> would be good, to get a template out there that can be used by
> other architecture maintainers.

I am currently porting the framework over to powerpc.  I will share
the initial patches in couple of days.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
