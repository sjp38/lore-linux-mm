Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 928D16B005C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:20:04 -0400 (EDT)
Message-ID: <4FEDFFB5.3010401@redhat.com>
Date: Fri, 29 Jun 2012 15:19:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>  <1340888180-15355-14-git-send-email-aarcange@redhat.com>  <1340895238.28750.49.camel@twins>  <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>  <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com>  <1340995260.28750.103.camel@twins> <4FEDF81C.1010401@redhat.com>  <1340996224.28750.116.camel@twins> <1340996586.28750.122.camel@twins>
In-Reply-To: <1340996586.28750.122.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/29/2012 03:03 PM, Peter Zijlstra wrote:
> On Fri, 2012-06-29 at 20:57 +0200, Peter Zijlstra wrote:
>> On Fri, 2012-06-29 at 14:46 -0400, Rik van Riel wrote:
>>>
>>> I am not convinced all architectures that have CONFIG_NUMA
>>> need to be a requirement, since some of them (eg. Alpha)
>>> seem to be lacking a maintainer nowadays.
>>
>> Still, this NUMA balancing stuff is not a small tweak to load-balancing.
>> Its a very significant change is how you schedule. Having such great
>> differences over architectures isn't something I look forward to.

I am not too worried about the performance of architectures
that are essentially orphaned :)

> Also, Andrea keeps insisting arch support is trivial, so I don't see the
> problem.

Getting it implemented in one or two additional architectures
would be good, to get a template out there that can be used by
other architecture maintainers.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
