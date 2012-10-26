Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 37D886B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 10:11:30 -0400 (EDT)
Message-ID: <1351260672.16863.81.camel@twins>
Subject: Re: [PATCH 26/31] sched, numa, mm: Add fault driven placement and
 migration policy
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 26 Oct 2012 16:11:12 +0200
In-Reply-To: <20121026135024.GA11640@gmail.com>
References: <20121025121617.617683848@chello.nl>
	 <20121025124834.467791319@chello.nl>
	 <CA+55aFwJdn8Kz9UByuRfGNtf9Hkv-=8xB+WRd47uHZU1YMagZw@mail.gmail.com>
	 <20121026071532.GC8141@gmail.com> <20121026135024.GA11640@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-10-26 at 15:50 +0200, Ingo Molnar wrote:
>=20
> Oh, just found the reason:
>=20
> the ptep_modify_prot_start()/modify()/commit() sequence is=20
> SMP-unsafe - it has to be done under the mmap_sem write-locked.
>=20
> It is safe against *hardware* updates to the PTE, but not safe=20
> against itself.=20

Shouldn't the pte_lock serialize all that still? All sites that modify
PTE contents should hold the pte_lock (and do afaict).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
