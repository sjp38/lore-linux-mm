Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B32EA6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 15:50:33 -0500 (EST)
Subject: Re: [PATCH 19/21] mm: Convert i_mmap_lock and anon_vma->lock to
 mutexes
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101129120530.67013aeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101126143843.801484792@chello.nl>
	 <20101126145411.331356698@chello.nl>
	 <20101129120530.67013aeb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 29 Nov 2010 21:50:42 +0100
Message-ID: <1291063842.32004.386.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-29 at 12:05 +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 26 Nov 2010 15:39:02 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Straight fwd conversion of i_mmap_lock and anon_vma->lock to mutexes.
> >=20
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>=20
> No performance influence ?

I couldn't find any, if there was anything the error and per-boot
deviation was larger.

Yanmin also ran this though the intel test/performance farm and didn't
find anything significant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
