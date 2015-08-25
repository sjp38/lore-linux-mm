Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA366B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 15:03:02 -0400 (EDT)
Received: by ykbi184 with SMTP id i184so165293948ykb.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 12:03:02 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id 17si34887482qgn.39.2015.08.25.12.03.01
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 12:03:01 -0700 (PDT)
Date: Tue, 25 Aug 2015 15:03:00 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150825190300.GG17005@akamai.com>
References: <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <20150825134154.GB6285@dhcp22.suse.cz>
 <20150825142902.GF17005@akamai.com>
 <20150825185829.GA10222@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FwyhczKCDPOVeYh6"
Content-Disposition: inline
In-Reply-To: <20150825185829.GA10222@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org


--FwyhczKCDPOVeYh6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Aug 2015, Michal Hocko wrote:

> On Tue 25-08-15 10:29:02, Eric B Munson wrote:
> > On Tue, 25 Aug 2015, Michal Hocko wrote:
> [...]
> > > Considering the current behavior I do not thing it would be terrible
> > > thing to do what Konstantin was suggesting and populate only the full
> > > ranges in a best effort mode (it is done so anyway) and document the
> > > behavior properly.
> > > "
> > >        If the memory segment specified by old_address and old_size is
> > >        locked (using mlock(2) or similar), then this lock is maintain=
ed
> > >        when the segment is resized and/or relocated. As a consequence,
> > >        the amount of memory locked by the process may change.
> > >=20
> > >        If the range is already fully populated and the range is
> > >        enlarged the new range is attempted to be fully populated
> > >        as well to preserve the full mlock semantic but there is no
> > >        guarantee this will succeed. Partially populated (e.g. created=
 by
> > >        mlock(MLOCK_ONFAULT)) ranges do not have the full mlock semant=
ic
> > >        so they are not populated on resize.
> > > "
> >=20
> > You are proposing that mremap would scan the PTEs as Vlastimil has
> > suggested?
>=20
> As Vlastimil pointed out this would be unnecessarily too costly. But I
> am wondering whether we should populate at all during mremap considering
> the full mlock semantic is not guaranteed anyway. Man page mentions only
> that the lock is maintained which will be true without population as
> well.
>=20
> If somebody really depends on the current (and broken) implementation we
> can offer MREMAP_POPULATE which would do a best effort population. This
> would be independent on the locked state and would be usable for other
> mappings as well (the usecase would be to save page fault overhead by
> batching them).
>=20
> If this would be seen as an unacceptable user visible change of behavior
> then we can go with the VMA flag but I would still prefer to not export
> it to the userspace so that we have a way to change this in future.

Would you drop your objections to the VMA flag if I drop the portions of
the patch that expose it to userspace?

The rework to not use the VMA flag is pretty sizeable and is much more
ugly IMO.  I know that you are not wild about using bit 30 of 32 for
this, but perhaps we can settle on not exporting it to userspace so we
can reclaim it if we really need it in the future?  I can teach the
folks here to check for size vs RSS of the locked mappings for stats on
lock on fault usage so from my point of view, the proc changes are not
necessary.

> --=20
> Michal Hocko
> SUSE Labs

--FwyhczKCDPOVeYh6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV3LvkAAoJELbVsDOpoOa9wcMP/34NMjAezJkjHohDYdGY0bb7
njohhtenqydNnRIotHkBOi3mADsSrvI5OocTM9+/D888I34cXkB8Odo99E7YZAaF
XxK1+NiuIPpdsINuL+LAbe9ZtmUUS2IfULHXLM/mK8hf7vimJ0IwFMI/tijHyvMz
VnL2fm1m15pUY7oPo6CskT25XvimwI4Z5HWEX82pSnBJjC9132VOnDYgDN75npjK
teRpNY0cTxuy/zHN2gSjznNtYB4Vb8NE1s/lVHdHKycAAyrdW6Q7X9DW4c09R8XE
HhK0GTmPXEwHzXPkPJIQf+UQyx76e38TvZob7nFx0t4/SEQFtDJ3Dl2gs6c+0aZa
oh6mqv5XJ1hPtHVUIK6+DU10JZuLEt02plJaGV/c/VCX+p89/Kv4TZiUWqDbeY0U
mt56wrWjE1gRnnEUi0awxICRDI0jib0+uNsG5K+Krd5gLAtsu1PiwslKRiHnBexY
BTVQK7dBWM78KPBWN5oCTYn1D6u8CaVrlI5ehUv3wm0FP3XDkJAB5urDIU9mVOOY
mvTf7i9w/wxyZ12IbpSu8SkwQnEG/VoZJJJg4E1PhXc+GkfJXKQYHx307CTVdAwB
FYKZ1fP+f5uqGNYPYcyRXbi/PgWbtomiW8o29DvvKy845A+lcT1Y1g7awPZ+DkFS
LgQLfyYBgz/KflXMALv3
=3Geq
-----END PGP SIGNATURE-----

--FwyhczKCDPOVeYh6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
