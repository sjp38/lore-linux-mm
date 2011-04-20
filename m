Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 97A238D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 07:04:46 -0400 (EDT)
Subject: Re: [PATCH 13/20] lockdep, mutex: Provide mutex_lock_nest_lock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130654.95a14117.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121725.940769985@chello.nl>
	 <20110419130654.95a14117.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 13:03:56 +0200
Message-ID: <1303297436.8345.158.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Tue, 2011-04-19 at 13:06 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:13:11 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Provide the mutex_lock_nest_lock() annotation.
>=20
> why?
>=20
> Neither the changelog nor the code provide any documentation for this add=
ition to
> the lokdep API.

---
Subject: lockdep, mutex: Provide mutex_lock_nest_lock                      =
                 =20
From: Peter Zijlstra <a.p.zijlstra@chello.nl>                              =
                 =20
Date: Fri, 26 Nov 2010 15:39:00 +0100                                      =
                 =20
                                                                           =
                 =20
In order to convert i_mmap_lock to a mutex we need a mutex equivalent      =
                 =20
to spin_lock_nest_lock(), thus provide the mutex_lock_nest_lock()          =
                 =20
annotation.                                                                =
                 =20
                                                                           =
                 =20
As with spin_lock_nest_lock(), mutex_lock_nest_lock() allows               =
                 =20
annotation of the locking pattern where an outer lock serializes the       =
                 =20
acquisition order of nested locks. That is, if every time you lock         =
                  =20
multiple locks A, say A1 and A2 you first acquire N, the order of          =
                 =20
acquiring A1 and A2 is irrelevant.                                         =
                 =20
                                                                           =
                 =20
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl> =20
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
