Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB1206B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 15:49:03 -0500 (EST)
Subject: Re: [PATCH 18/21] mutex: Provide mutex_is_contended
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101129115803.da384e25.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101126143843.801484792@chello.nl>
	 <20101126145411.270875001@chello.nl>
	 <20101129115803.da384e25.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 29 Nov 2010 21:49:03 +0100
Message-ID: <1291063743.32004.381.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-29 at 11:58 +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 26 Nov 2010 15:39:01 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Usable for lock-breaks and such.
> >=20
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>=20
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>=20
> Could you update API list in Documentation/mutex-design.txt ?

Not sure what to update there, one could add a single like to the end,
not sure documentation really is the answer here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
