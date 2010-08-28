Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EEBB86B01F0
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 06:17:13 -0400 (EDT)
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.1008272136220.28501@router.home>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	 <20100826235052.GZ6803@random.random>
	 <AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
	 <20100827095546.GC6803@random.random>
	 <AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
	 <alpine.DEB.2.00.1008271159160.18495@router.home>
	 <AANLkTi=FeHnLu4_6M5N6yUL==4YyxVXXxsccsE2kNUbm@mail.gmail.com>
	 <alpine.DEB.2.00.1008271420400.18495@router.home>
	 <AANLkTinLpDnpwr40dtU5UFq53avODSKxTA4=xnZwmJFX@mail.gmail.com>
	 <alpine.DEB.2.00.1008271547200.22988@router.home>
	 <AANLkTim16oT13keYK_oz=7kmDmdG=ADfkGXMKp3_dEw_@mail.gmail.com>
	 <AANLkTikML=HghpOVK0WZ0t6CRaNOKvu=57ebojZ+YCNS@mail.gmail.com>
	 <alpine.DEB.2.00.1008271801080.25115@router.home>
	 <AANLkTindjNiJXbfsWbFexXBQVB174aprhSbBLFosBvC=@mail.gmail.com>
	 <alpine.DEB.2.00.1008272136220.28501@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sat, 28 Aug 2010 12:17:06 +0200
Message-ID: <1282990626.1975.3270.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-27 at 21:47 -0500, Christoph Lameter wrote:
>=20
> I'd be much more comfortable if the following would be done
>=20
> A. Pin the anon_vma by either
>         I. Take a refcount on the anon vma

My preemptible mmu patches do that..

>         II. Take a lock in the anon vma (something that is not pointed to=
)
>=20
> B. Either
>         I. All values that have been used before the pinning are
>            verified after the pinning (and the lock is reacquired
>            if verification fails).
>=20
>         II. Or all functions using page_lock_anon_vma() must securely
>             work in the case that the anon_vma was reused for
>             something else before the vma lock was acquired.

Last time I looked they all work like that, they all use something akin
to vma_address() which validates that the page we're interested in is
indeed part of the vma we obtained from the rmap chain.

Anyway, I'll try and refresh my preemptible mmu patch-set now that the
merge window dust settled and post if again, hopefully we can stick it
in -next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
