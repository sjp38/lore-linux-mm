Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 8FBE76B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 11:02:56 -0400 (EDT)
Message-ID: <1341586950.7709.55.camel@twins>
Subject: Re: [RFC][PATCH 02/26] mm, mpol: Remove NUMA_INTERLEAVE_HIT
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 06 Jul 2012 17:02:30 +0200
In-Reply-To: <20120706144820.GC2328@barrios>
References: <20120316144028.036474157@chello.nl>
	 <20120316144240.234456258@chello.nl> <20120706103255.GA23680@cmpxchg.org>
	 <20120706144820.GC2328@barrios>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-07-06 at 23:48 +0900, Minchan Kim wrote:
>=20
> I alreay sent a patch about that but didn't have a reply from
> Peter/Ingo.
>=20
> https://lkml.org/lkml/2012/7/3/477=20

Yeah sorry for that.. it looks like Ingo picked up the fix from hnaz
though.

Thanks both!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
