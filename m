Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D1A4A6B006E
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:48:19 -0400 (EDT)
Message-ID: <4FEDF81C.1010401@redhat.com>
Date: Fri, 29 Jun 2012 14:46:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>  <1340888180-15355-14-git-send-email-aarcange@redhat.com>  <1340895238.28750.49.camel@twins>  <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>  <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995260.28750.103.camel@twins>
In-Reply-To: <1340995260.28750.103.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/29/2012 02:41 PM, Peter Zijlstra wrote:
> On Fri, 2012-06-29 at 12:51 -0400, Dor Laor wrote:
>> t's hard to say whether Peter's like to add ia64 support or
>> just like to get rid of the forceful migration as a whole.
>
> I've stated several times that all archs that have CONFIG_NUMA must be
> supported before we can consider any of this. I've no intention of doing
> so myself. Andrea wants this, Andrea gets to do it.

I am not convinced all architectures that have CONFIG_NUMA
need to be a requirement, since some of them (eg. Alpha)
seem to be lacking a maintainer nowadays.

It would be good if Andrea could touch base with the maintainers
of the actively maintained architectures with NUMA, and get them
to sign off on the way autonuma does things, and work with them
to get autonuma ported to those architectures.

> I've also stated several times that forceful migration in the context of
> numa balancing must go.

I am not convinced about this part either way.

I do not see how a migration numa thread (which could potentially
use idle cpu time) will be any worse than migrate on fault, which
will always take away time from the userspace process.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
