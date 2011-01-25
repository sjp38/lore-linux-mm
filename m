Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4286B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 16:08:45 -0500 (EST)
Subject: Re: [PATCH 00/25] mm: Preemptibility -v7
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4D3F36CB.6060505@linux.intel.com>
References: <20110125173111.720927511@chello.nl>
	 <m2ipxcsr6v.fsf@linux.intel.com> <1295987985.28776.1118.camel@laptop>
	 <4D3F36CB.6060505@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 25 Jan 2011 22:09:30 +0100
Message-ID: <1295989770.28776.1127.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, benh <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-01-25 at 12:47 -0800, Andi Kleen wrote:
>=20
> I thought the reason for the preempt off inside the mmu gather region was
> to stay on the same CPU for local/remote flushes. How would it change tha=
t?=20

afaik its been preempt-off solely because it was always inside a number
of spinlocks, I know both Hugh and BenH worked on making it preemptible
far before I started this.

I remember Hugh and Nick talking about this at OLS'06 or 07, can't
really remember.

As to local/remote flushes, there is no real saying where the pages came
from due to on-demand paging and the scheduler never having had a notion
of home-node. Therefore freeing them wouldn't be more of less local if
that is exposed to the same migration as allocation was.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
