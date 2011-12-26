Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 017AF6B005A
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 01:57:25 -0500 (EST)
Date: Mon, 26 Dec 2011 08:57:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 5/6] memcg: fix broken boolen expression
Message-ID: <20111226065724.GA13459@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
 <1324695619-5537-5-git-send-email-kirill@shutemov.name>
 <20111226153138.0376bd66.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20111226153138.0376bd66.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, stable@vger.kernel.org

On Mon, Dec 26, 2011 at 03:31:38PM +0900, KAMEZAWA Hiroyuki wrote:
> On Sat, 24 Dec 2011 05:00:18 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>=20
> > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> >=20
> > action !=3D CPU_DEAD || action !=3D CPU_DEAD_FROZEN is always true.
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>=20
> maybe this should go stable..

CC stable@

>=20
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>=20
>=20
> > ---
> >  mm/memcontrol.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index b27ce0f..3833a7b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2100,7 +2100,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(s=
truct notifier_block *nb,
> >  		return NOTIFY_OK;
> >  	}
> > =20
> > -	if ((action !=3D CPU_DEAD) || action !=3D CPU_DEAD_FROZEN)
> > +	if (action !=3D CPU_DEAD && action !=3D CPU_DEAD_FROZEN)
> >  		return NOTIFY_OK;
> > =20
> >  	for_each_mem_cgroup(iter)
> > --=20
> > 1.7.7.3
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe cgroups" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
