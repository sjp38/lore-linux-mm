Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 3C90A6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 03:30:10 -0400 (EDT)
Message-ID: <4FF14DDF.8000201@redhat.com>
Date: Mon, 02 Jul 2012 03:29:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995986.28750.114.camel@twins> <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com> <20120630012338.GY6676@redhat.com> <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com> <4FEE9310.1050908@redhat.com> <CAPQyPG5h=p2buvCyNjD=fc2zjpVkashe0FppE9X2KNp-C-b3Yw@mail.gmail.com>
In-Reply-To: <CAPQyPG5h=p2buvCyNjD=fc2zjpVkashe0FppE9X2KNp-C-b3Yw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: dlaor@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/30/2012 04:23 AM, Nai Xia wrote:

> Oh, sorry, I think I forgot few last comments in my last post:
>
> In case you really can take my advice and do comprehensive research,
> try to make sure that you compare the result of your fancy sampling algorithm
> with this simple logic:
>
>     "Blindly select a node and bind the process and move all pages to it."
>
> Stupid it may sound, I highly suspect it can approach the benchmarks
> you already did.
>
> If that's really the truth, then all the sampling and weighting stuff can
> be cut off.

All the sampling and weighing is there in order to deal with
processes that do not fit in one NUMA node.

This could be either a process that uses more memory than
what fits in one NUMA node, or a process with more threads
than there are processors in a NUMA node, or both.

That is what the complex code is for.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
