Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 695CE6B0116
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:16:15 -0400 (EDT)
Date: Thu, 4 Oct 2012 14:16:14 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 29/33] autonuma: page_autonuma
In-Reply-To: <1349308275-2174-30-git-send-email-aarcange@redhat.com>
Message-ID: <0000013a2c223da2-632aa43e-21f8-4abd-a0ba-2e1b49881e3a-000000@email.amazonses.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <1349308275-2174-30-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 4 Oct 2012, Andrea Arcangeli wrote:

> Move the autonuma_last_nid from the "struct page" to a separate
> page_autonuma data structure allocated in the memsection (with
> sparsemem) or in the pgdat (with flatmem).

Note that there is a available word in struct page before the autonuma
patches on x86_64 with CONFIG_HAVE_ALIGNED_STRUCT_PAGE.

In fact the page_autonuma fills up the structure to nicely fit in one 64
byte cacheline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
