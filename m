Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 2FA436B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 05:46:06 -0400 (EDT)
Message-ID: <1332409539.18960.508.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 22 Mar 2012 10:45:39 +0100
In-Reply-To: <CAOhV88NafiU7hseTzQfApthMk3X=_GT09gEM2Zzx5OJ=8z6vvw@mail.gmail.com>
References: <20120316144028.036474157@chello.nl>
	 <CAOhV88NafiU7hseTzQfApthMk3X=_GT09gEM2Zzx5OJ=8z6vvw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


> I was going to try and test this on power, but it fails to build:
>=20
>   mm/filemap_xip.c: In function =E2=80=98__xip_unmap=E2=80=99:
>   mm/filemap_xip.c:199: error: implicit declaration of function
> =E2=80=98numa_add_vma_counter=E2=80=99

Add:=20

#include <linux/mempolicy.h>

to that file and it should build.

> >  [26/26] sched, numa: A few debug bits
>=20
> introduced a new warning:
>=20
>   kernel/sched/numa.c: In function =E2=80=98process_cpu_runtime=E2=80=99:
>   kernel/sched/numa.c:210: warning: format =E2=80=98%lu=E2=80=99 expects =
type =E2=80=98long
> unsigned int=E2=80=99, but argument 3 has type =E2=80=98u64=E2=80=99
>   kernel/sched/numa.c:210: warning: format =E2=80=98%lu=E2=80=99 expects =
type =E2=80=98long
> unsigned int=E2=80=99, but argument 4 has type =E2=80=98u64=E2=80=99

Yeah, that's a known trainwreck, some archs define u64 as unsigned long
others as unsigned long long, so whatever you write: %ul or %ull is
wrong and I can't be arsed to add an explict cast since its all debug
bits that won't ever make it in anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
