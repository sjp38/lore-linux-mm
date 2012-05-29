Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 16B126B0062
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:47:23 -0400 (EDT)
Message-ID: <4FC4FD51.2080001@redhat.com>
Date: Tue, 29 May 2012 12:46:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <1337965359-29725-14-git-send-email-aarcange@redhat.com> <1338297385.26856.74.camel@twins> <20120529163849.GF21339@redhat.com>
In-Reply-To: <20120529163849.GF21339@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On 05/29/2012 12:38 PM, Andrea Arcangeli wrote:
> On Tue, May 29, 2012 at 03:16:25PM +0200, Peter Zijlstra wrote:
>> 24 bytes per page.. or ~0.6% of memory gone. This is far too great a
>> price to pay.
>
> I don't think it's too great, memcg uses for half of that and yet
> nobody is booting with cgroup_disable=memory even on not-NUMA servers
> with less RAM.

Not any more.

Ever since the memcg naturalization work by Johannes,
a page is only ever on one LRU list and the memcg
memory overhead is gone.

> But I'm all for experimenting. It's just not something I had the time
> to try yet. I will certainly love to see how it performs by reducing
> the max size of the list. I totally agree it's a good idea to try it
> out, and I don't exclude it will work fine, but it's not obvious it's
> worth the memory saving.

That's fair enough.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
