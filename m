Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 826A06B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 20:23:18 -0400 (EDT)
Date: Fri, 12 Oct 2012 00:23:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 07/33] autonuma: mm_autonuma and task_autonuma data
 structures
In-Reply-To: <5076E4B2.2040301@redhat.com>
Message-ID: <0000013a525a8739-2b4049fa-1cb3-4b8f-b3a7-1fa77b181590-000000@email.amazonses.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <1349308275-2174-8-git-send-email-aarcange@redhat.com> <20121011122827.GT3317@csn.ul.ie> <5076E4B2.2040301@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 11 Oct 2012, Rik van Riel wrote:

> These statistics are updated at page fault time, I
> believe while holding the page table lock.
>
> In other words, they are in code paths where updating
> the stats should not cause issues.

The per cpu counters in the VM were introduced because of
counter contention caused at page fault time. This is the same code path
where you think that there cannot be contention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
