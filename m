Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5518D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 07:40:25 -0500 (EST)
Subject: Re: [PATCH] mm: don't return 0 too early from find_get_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1102232132080.2239@sister.anvils>
References: <alpine.LSU.2.00.1102232132080.2239@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 24 Feb 2011 13:40:13 +0100
Message-ID: <1298551213.2428.43.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Salman Qazi <sqazi@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2011-02-23 at 21:35 -0800, Hugh Dickins wrote:
> Callers of find_get_pages(), or its wrapper pagevec_lookup() - notably
> truncate_inode_pages_range() - stop looking further when it returns 0.
>=20
> But if an interrupt comes just after its radix_tree_gang_lookup_slot(),
> especially if we have preemptible RCU enabled, isn't it conceivable
> that all 14 pages returned could be removed from the page cache by
> shrink_page_list(), before find_get_pages() gets to process them?  So
> causing it to return 0 although there may be plenty more pages beyond.
>=20
> Make find_get_pages() and find_get_pages_tag() check for this unlikely
> case, and restart should it occur; but callers of find_get_pages_contig()
> have no such expectation, it's okay for that to return 0 early.
>=20
> I have not seen this in practice, just worried by the possibility.
>=20
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
