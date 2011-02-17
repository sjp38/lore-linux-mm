Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 71E568D003A
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:36:46 -0500 (EST)
Subject: Re: [PATCH 0/8] mm: Preemptibility -v8
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110217170520.229881980@chello.nl>
References: <20110217170520.229881980@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 17 Feb 2011 18:36:24 +0100
Message-ID: <1297964184.2413.2029.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Thu, 2011-02-17 at 18:05 +0100, Peter Zijlstra wrote:
> This series depends on the previous two series:
>   - mm: Simplify anon_vma lifetime rules
>   - mm: mmu_gather rework
>=20
> These patches make part of the mm a lot more preemptible. It converts
> i_mmap_lock and anon_vma->lock to mutexes which together with the mmu_gat=
her
> rework makes mmu_gather preemptible as well.
>=20
> Making i_mmap_lock a mutex also enables a clean-up of the truncate code.
>=20
> This also allows for preemptible mmu_notifiers, something that XPMEM I th=
ink
> wants.

---
 Documentation/lockstat.txt   |    2=20
 Documentation/vm/locking     |    2=20
 arch/x86/mm/hugetlbpage.c    |    4=20
 fs/gfs2/main.c               |    2=20
 fs/hugetlbfs/inode.c         |    4=20
 fs/inode.c                   |    2=20
 fs/nilfs2/page.c             |    2=20
 include/linux/fs.h           |    3=20
 include/linux/huge_mm.h      |    8 -
 include/linux/lockdep.h      |    3=20
 include/linux/mm.h           |    2=20
 include/linux/mm_types.h     |    1=20
 include/linux/mmu_notifier.h |    2=20
 include/linux/mutex.h        |    9 +
 include/linux/rmap.h         |   29 +-----
 kernel/fork.c                |    5 -
 kernel/mutex.c               |   25 +++--
 mm/filemap.c                 |   10 +-
 mm/filemap_xip.c             |    4=20
 mm/fremap.c                  |    4=20
 mm/huge_memory.c             |    4=20
 mm/hugetlb.c                 |   14 +--
 mm/memory-failure.c          |    4=20
 mm/memory.c                  |  197 ++++++--------------------------------=
-----
 mm/migrate.c                 |   17 ---
 mm/mmap.c                    |   43 +++------
 mm/mremap.c                  |    7 -
 mm/rmap.c                    |  171 +++++++++++++++++++++++++++++--------
 28 files changed, 258 insertions(+), 322 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
