Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB196B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 00:54:06 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so17423039pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 21:54:06 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id w5si14527671pfa.177.2016.01.27.21.54.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 21:54:05 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm/madvise: update comment on sys_madvise()
Date: Thu, 28 Jan 2016 05:50:56 +0000
Message-ID: <20160128055055.GA8747@hori1.linux.bs1.fc.nec.co.jp>
References: <1453857865-13650-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160127152835.GD13956@dhcp22.suse.cz>
In-Reply-To: <20160127152835.GD13956@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3921E6AA12F5DC49B2BD906980B38557@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jason Baron <jbaron@redhat.com>, Chen Gong <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jan 27, 2016 at 04:28:35PM +0100, Michal Hocko wrote:
> On Wed 27-01-16 10:24:25, Naoya Horiguchi wrote:
> > Some new MADV_* advices are not documented in sys_madvise() comment.
> > So let's update it.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> Other than few suggestions below
> Acked-by: Michal Hocko <mhocko@suse.com>
>=20
> > ---
> >  mm/madvise.c | 12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> >=20
> > diff --git v4.4-mmotm-2016-01-20-16-10/mm/madvise.c v4.4-mmotm-2016-01-=
20-16-10_patched/mm/madvise.c
> > index 6a77114..c897b15 100644
> > --- v4.4-mmotm-2016-01-20-16-10/mm/madvise.c
> > +++ v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
> > @@ -639,14 +639,26 @@ madvise_behavior_valid(int behavior)
> >   *		some pages ahead.
> >   *  MADV_DONTNEED - the application is finished with the given range,
> >   *		so the kernel can free resources associated with it.
> > + *  MADV_FREE - the application marks pages in the given range as lasy=
free,
>=20
> s@lasyfree@lazy free@
>=20
> > + *		where actual purges are postponed until memory pressure happens.
> >   *  MADV_REMOVE - the application wants to free up the given range of
> >   *		pages and associated backing store.
> >   *  MADV_DONTFORK - omit this area from child's address space when for=
king:
> >   *		typically, to avoid COWing pages pinned by get_user_pages().
> >   *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when =
forking.
> > + *  MADV_HWPOISON - trigger memory error handler as if the given memor=
y range
> > + *		were corrupted by unrecoverable hardware memory failure.
> > + *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
> >   *  MADV_MERGEABLE - the application recommends that KSM try to merge =
pages in
> >   *		this area with pages of identical content from other such areas.
> >   *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages wit=
h others.
> > + *  MADV_HUGEPAGE - the application wants to allocate transparent huge=
pages to
> > + *		load the content of the given memory range.
>=20
> I guess that a slightly different wording would be better:
>=20
> application wants to back the given range by transparent huge pages in
> the future. Existing pages might be coalesced and new pages might be
> allocated as THP.
>=20
> > + *  MADV_NOHUGEPAGE - cancel MADV_HUGEPAGE: no longer allocate transpa=
rent
> > + *		hugepages.
>=20
> Mark the given range as not worth being backed by transparent huge pages
> so neither existing pages will be coalesced into THP nor new pages will
> be allocated as THP.

Thank you for the elaboration.
I'm fine for all these change.

- Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
