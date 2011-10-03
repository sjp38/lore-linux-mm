Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E76E69000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 17:07:09 -0400 (EDT)
Subject: Re: lockdep recursive locking detected (rcu_kthread / __cache_free)
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 03 Oct 2011 23:06:19 +0200
In-Reply-To: <alpine.DEB.2.00.1110031540560.11713@router.home>
References: <20111003175322.GA26122@sucs.org>
	 <20111003203139.GH2403@linux.vnet.ibm.com>
	 <alpine.DEB.2.00.1110031540560.11713@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317675980.9417.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Mon, 2011-10-03 at 15:46 -0500, Christoph Lameter wrote:
> On Mon, 3 Oct 2011, Paul E. McKenney wrote:
>=20
> > The first lock was acquired here in an RCU callback.  The later lock th=
at
> > lockdep complained about appears to have been acquired from a recursive
> > call to __cache_free(), with no help from RCU.  This looks to me like
> > one of the issues that arise from the slab allocator using itself to
> > allocate slab metadata.
>=20
> Right. However, this is a false positive since the slab cache with
> the metadata is different from the slab caches with the slab data. The sl=
ab
> cache with the metadata does not use itself any metadata slab caches.

Sure, but we're supposed to have annotated that.. see
init_node_lock_keys()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
