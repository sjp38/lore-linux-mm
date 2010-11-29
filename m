Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 984588D0007
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 06:42:08 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1291021220.32570.295.camel@pasglop>
References: <20101126143843.801484792@chello.nl>
	 <1291021220.32570.295.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 29 Nov 2010 12:41:56 +0100
Message-ID: <1291030916.32004.7.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-29 at 20:00 +1100, Benjamin Herrenschmidt wrote:
> > Linus seems to want this to get some serious review and be pushed throu=
gh
> > Andrew (well, anybody but me actually, but since Andrew is mm master...=
)
> >=20
> > Ben, Thomas, Andrew, can I trick you guys into looking at this stuff?
>=20
> It's on my hot todo list this week :-)
>=20
> I'd like to take out the rcu fix for ppc page table freeing tho and send
> it to Linus now if you're ok with that.

Sure, and thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
