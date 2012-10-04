Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9D5F46B0130
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:17:39 -0400 (EDT)
Date: Thu, 4 Oct 2012 18:17:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: your mail
In-Reply-To: <20121004165008.GF25675@redhat.com>
Message-ID: <0000013a2cff3c3d-76e00716-2869-4dc8-8717-82f0136018d0-000000@email.amazonses.com>
References: <20121004165008.GF25675@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, 4 Oct 2012, Andrea Arcangeli wrote:

> So we could drop page_autonuma by creating a CONFIG_SLUB=y dependency
> (AUTONUMA wouldn't be available in the kernel config if SLAB=y, and it
> also wouldn't be available on 32bit archs but the latter isn't a
> problem).

Nope it should depend on page struct alignment. Other kernel subsystems
may be depeding on page struct alignment in the future (and some other
arches may already have that requirement)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
