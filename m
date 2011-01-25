Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D956B6B00E8
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:30:32 -0500 (EST)
Subject: Re: [PATCH 20/25] mm: Simplify anon_vma refcounts
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <AANLkTikchW7Z6mSgcbt7wn9DWTeEGrKwfMwj1_WjMB5c@mail.gmail.com>
References: <20110125173111.720927511@chello.nl>
	 <20110125174908.262260777@chello.nl>
	 <AANLkTikchW7Z6mSgcbt7wn9DWTeEGrKwfMwj1_WjMB5c@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 25 Jan 2011 21:31:01 +0100
Message-ID: <1295987461.28776.1110.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2011-01-26 at 06:16 +1000, Linus Torvalds wrote:
> On Wed, Jan 26, 2011 at 3:31 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> =
wrote:
> >
> > This patch changes the anon_vma refcount to be 0 when the object is
> > free. It does this by adding 1 ref to being in use in the anon_vma
> > structure (iow. the anon_vma->head list is not empty).
>=20
> Why is this patch part of this series, rather than being an
> independent patch before the whole series?
>=20
> I think this part of the series is the only total no-brainer, ie we
> should have done this from the beginning. The preemptability stuff I'm
> more nervous about (performance issues? semantic differences?)

It relies on patch 19, which moves the anon_vma refcount out from under
CONFIG_goo.

If however you like it, I can move 19 and this patch up to the start and
have that go your way soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
