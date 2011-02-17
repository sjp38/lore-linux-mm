Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6ED8D003A
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:36:36 -0500 (EST)
Subject: Re: [PATCH 0/3] mm: Simplify anon_vma lifetime rules
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110217161948.045410404@chello.nl>
References: <20110217161948.045410404@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 17 Feb 2011 18:36:16 +0100
Message-ID: <1297964176.2413.2027.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Thu, 2011-02-17 at 17:19 +0100, Peter Zijlstra wrote:
> As per Linus' request, isolate these three patches.

---
 include/linux/rmap.h |   45 ++++++---------------------
 mm/ksm.c             |   23 +++-----------
 mm/migrate.c         |    4 +-
 mm/rmap.c            |   83 +++++++++++++++++-----------------------------=
-----
 4 files changed, 46 insertions(+), 109 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
