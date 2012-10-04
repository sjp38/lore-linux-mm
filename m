Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 6F2746B0153
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 16:50:07 -0400 (EDT)
Message-ID: <506DF64D.4000303@redhat.com>
Date: Thu, 04 Oct 2012 16:49:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/33] AutoNUMA27
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <20121004113943.be7f92a0.akpm@linux-foundation.org>
In-Reply-To: <20121004113943.be7f92a0.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 10/04/2012 02:39 PM, Andrew Morton wrote:
> On Thu,  4 Oct 2012 01:50:42 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
>
>> This is a new AutoNUMA27 release for Linux v3.6.
>
> Peter's numa/sched patches have been in -next for a week.  Guys, what's the
> plan here?

Both AutoNUMA and sched/numa have been extremely useful
development trees, allowing us to learn a lot about what
functionality we do (and do not) require to get NUMA
placement and scheduling to work correctly.

The AutoNUMA code base seems to work right, but may be
complex for some people. It could be simplified to
people's tastes and merged.

The sched/numa code base is not quite ready, but is
rapidly getting there. The way things are going now,
I would give it another week or two?

A few inefficiencies in the sched/numa migration code
were fixed earlier today, and cpu-follows-memory code
is being added as we speak. Both code bases should be
functionally similar real soon now.

That leaves the choice up to you folks :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
