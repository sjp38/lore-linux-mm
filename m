Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 8C0176B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 12:01:46 -0500 (EST)
Date: Sun, 1 Jan 2012 19:01:44 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/5] memcg: trivial cleanups
Message-ID: <20120101170144.GA3203@shutemov.name>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Sat, Dec 31, 2011 at 11:26:42PM -0800, Hugh Dickins wrote:
> Obviously I've missed the boat for per-memcg per-zone LRU locking in 3.3,
> but I've split out a shameless bunch of trivial cleanups from that work,
> and hoping these might still sneak in unless they're controversial.
>=20
> Following on from my earlier mmotm/next patches, here's five
> to memcontrol.c and .h, followed by six to the rest of mm.
>=20
> [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
> [PATCH 2/5] memcg: replace mem and mem_cont stragglers
> [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
> [PATCH 4/5] memcg: enum lru_list lru
> [PATCH 5/5] memcg: remove redundant returns

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

>=20
>  include/linux/memcontrol.h |    2=20
>  mm/memcontrol.c            |  121 ++++++++++++++++-------------------
>  2 files changed, 58 insertions(+), 65 deletions(-)
>=20
> Hugh
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
=2Eca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
