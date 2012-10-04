Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 2582C6B013A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 15:11:53 -0400 (EDT)
Date: Thu, 4 Oct 2012 19:11:51 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 29/33] autonuma: page_autonuma
In-Reply-To: <20121004183819.GM25675@redhat.com>
Message-ID: <0000013a2d30ebf2-1a2bb821-92a0-464b-9db0-f960b2fd074d-000000@email.amazonses.com>
References: <20121004165008.GF25675@redhat.com> <0000013a2cff3c3d-76e00716-2869-4dc8-8717-82f0136018d0-000000@email.amazonses.com> <20121004183819.GM25675@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, 4 Oct 2012, Andrea Arcangeli wrote:

> If you mean CONFIG_AUTONUMA=y should select (not depend) on
> CONFIG_HAVE_ALIGNED_STRUCT_PAGE, that would allow to enable it in all
> .configs but it would have a worse cons: losing 8bytes per page
> unconditionally (even when booting on non-NUMA hardware).

I did not say anything like that. Still not convinced that autonuma is
worth doing and that it is beneficial given the complexity it adds to the
kernel. Just wanted to point out that there is a case to be made for
adding another word to the page struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
