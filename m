Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3F28C6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 15:42:06 -0500 (EST)
Subject: Re: [PATCH 07/21] mm: Use refcounts for page_lock_anon_vma()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101129113511.296169c9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101126143843.801484792@chello.nl>
	 <20101126145410.655255418@chello.nl>
	 <20101129113511.296169c9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 29 Nov 2010 21:41:23 +0100
Message-ID: <1291063283.32004.364.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-29 at 11:35 +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 26 Nov 2010 15:38:50 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Convert page_lock_anon_vma() over to use refcounts. This is
> > done for each of convertion of anon_vma from spinlock to mutex.
> >=20
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>=20
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>=20
> Does this patch affect only page_referenced() and try_to_unmap() ?

git grep page_lock_anon_vma reveals that
mm/memory-failure.c:collect_procs_anon() is also affected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
