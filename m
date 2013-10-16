Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 97AC36B0039
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 05:35:31 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so581059pbc.23
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 02:35:31 -0700 (PDT)
Received: by mail-bk0-f53.google.com with SMTP id d7so166767bkh.26
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 02:35:26 -0700 (PDT)
Date: Wed, 16 Oct 2013 11:33:09 +0200
From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH 0/11] update page table walker
Message-ID: <20131016093308.GD21963@ulmo.nvidia.com>
References: <1381772230-26878-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20131015134317.02d819f6905f790007ba1842@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2iBwrppp/7QCDedR"
Content-Disposition: inline
In-Reply-To: <20131015134317.02d819f6905f790007ba1842@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Mark Brown <broonie@kernel.org>


--2iBwrppp/7QCDedR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 15, 2013 at 01:43:17PM -0700, Andrew Morton wrote:
> On Mon, 14 Oct 2013 13:36:59 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
=2Ecom> wrote:
>=20
> > Page table walker is widely used when you want to traverse page table
> > tree and do some work for the entries (and pages pointed to by them.)
> > This is a common operation, and keep the code clean and maintainable
> > is important. Moreover this patchset introduces caller-specific walk
> > control function which is helpful for us to newly introduce page table
> > walker to some other users. Core change comes from patch 1, so please
> > see it for how it's supposed to work.
> >=20
> > This patchset changes core code in mm/pagewalk.c at first in patch 1 an=
d 2,
> > and then updates all of current users to make the code cleaner in patch
> > 3-9. Patch 10 changes the interface of hugetlb_entry(), I put it here to
> > keep bisectability of the whole patchset. Patch 11 applies page table w=
alker
> > to a new user queue_pages_range().
>=20
> Unfortunately this is very incompatible with pending changes in
> fs/proc/task_mmu.c.  Especially Kirill's "mm, thp: change
> pmd_trans_huge_lock() to return taken lock".
>=20
> Stephen will be away for a couple more weeks so I'll get an mmotm
> released and hopefully Thierry and Mark will scoop it up(?).=20
> Alternatively, http://git.cmpxchg.org/?p=3Dlinux-mmots.git;a=3Dsummary is
> up to date.
>=20
> Please take a look, decide what you think we should do?

Hi Andrew,

I haven't had the time to look at writing up the scripts to import the
mmotm into the linux-next trees that I create. From what I understand,
it might be unwise to just pull linux-mmots into linux-next because it
isn't very well tested. Then again, increasing test coverage is one of
the goals of linux-next. If you think it's safe to include linux-mmots
in linux-next I can easily do that.

Otherwise I'll see if I can resume work on the scripts I started to
import the mmotm. Stephen has also provided the scripts that he used,
but I haven't had much time to look at them in detail yet because of
other things that have been keeping me busy.

Thierry

--2iBwrppp/7QCDedR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSXl1UAAoJEN0jrNd/PrOhkbcP/3pB6Fc8Va/veibYv8MCTinU
eCglYT7+8DB/twBEvG548SN77IVkQxq22hVxPeFlH4RP6+cSaQlceZNtSQAwmn64
gYACitl+XKW3woxVuwn0TXar8KmscR+bCA1o53DtztJpxdomu1cSbfTpyA0uj0VY
VlgtDWtjmZHxb5Z9HWRl455y1RbSlA5C6TwCh0O7tyUkMMkQZp/qlFu/Vk1rfG5t
RC5t8uP2nP72s1jYZt2oekM73k3XLDzEfdCyAauajb2MxQbD2T3qAiKcGDNzy6mr
82bEXrgqby11bEX+oOOND+BF4IjJMAW4a6zQOSAkcXCPbGjI6VdIn1f5seFQ0SM3
1Gvh+YH+wNKX9pMLDON278RX9qAYxrq6kAl9JSoNu2+7ymKizGSGd4Lq+DPiU0Zc
7rzrPUUTuJaKEsUWhGnHRvuu/23N7tPIM1ePiiHGJcQu5RkrTfNmVRVZAEIWZgxi
aFZY+TudQsVoUO0tQ5vILPAc/NVpYT+IQT5ZvW4kKeg6OfMpuYzLrrDQTYJ7oeZL
8NlRsFL+klpBCYL/lj5V8yWf6KAmRShaRdoNfHqSJ0/suroN8pQF2OHuMb4End0N
zFG8bVoAyKbNaod1IqxHLRaBFIPr2Pe/t8WU2rXwtYsAAonEd0j98KnKtLKNP0bU
7jTtCXnd2+sMlqoLZtrk
=aA3/
-----END PGP SIGNATURE-----

--2iBwrppp/7QCDedR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
