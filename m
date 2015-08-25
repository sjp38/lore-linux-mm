Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id DA0816B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:29:03 -0400 (EDT)
Received: by qkda128 with SMTP id a128so51474681qkd.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:29:03 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id d64si33685423qhc.93.2015.08.25.07.29.02
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 07:29:03 -0700 (PDT)
Date: Tue, 25 Aug 2015 10:29:02 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150825142902.GF17005@akamai.com>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <20150825134154.GB6285@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lIrNkN/7tmsD/ALM"
Content-Disposition: inline
In-Reply-To: <20150825134154.GB6285@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org


--lIrNkN/7tmsD/ALM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Aug 2015, Michal Hocko wrote:

> On Fri 21-08-15 14:31:32, Eric B Munson wrote:
> [...]
> > I am in the middle of implementing lock on fault this way, but I cannot
> > see how we will hanlde mremap of a lock on fault region.  Say we have
> > the following:
> >=20
> >     addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >     mlock(addr, len, MLOCK_ONFAULT);
> >     ...
> >     mremap(addr, len, 2 * len, ...)
> >=20
> > There is no way for mremap to know that the area being remapped was lock
> > on fault so it will be locked and prefaulted by remap.  How can we avoid
> > this without tracking per vma if it was locked with lock or lock on
> > fault?
>=20
> Yes mremap is a problem and it is very much similar to mmap(MAP_LOCKED).
> It doesn't guarantee the full mlock semantic because it leaves partially
> populated ranges behind without reporting any error.

This was not my concern.  Instead, I was wondering how to keep lock on
fault sematics with mremap if we do not have a VMA flag.  As a user, it
would surprise me if a region I mlocked with lock on fault and then
remapped to a larger size was fully populated and locked by the mremap
call.

>=20
> Considering the current behavior I do not thing it would be terrible
> thing to do what Konstantin was suggesting and populate only the full
> ranges in a best effort mode (it is done so anyway) and document the
> behavior properly.
> "
>        If the memory segment specified by old_address and old_size is
>        locked (using mlock(2) or similar), then this lock is maintained
>        when the segment is resized and/or relocated. As a consequence,
>        the amount of memory locked by the process may change.
>=20
>        If the range is already fully populated and the range is
>        enlarged the new range is attempted to be fully populated
>        as well to preserve the full mlock semantic but there is no
>        guarantee this will succeed. Partially populated (e.g. created by
>        mlock(MLOCK_ONFAULT)) ranges do not have the full mlock semantic
>        so they are not populated on resize.
> "

You are proposing that mremap would scan the PTEs as Vlastimil has
suggested?

>=20
> So what we have as a result is that partially populated ranges are
> preserved and fully populated ones work in the best effort mode the same
> way as they are now.
>=20
> Does that sound at least remotely reasonably?
>=20
>=20
> --=20
> Michal Hocko
> SUSE Labs

--lIrNkN/7tmsD/ALM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV3HuuAAoJELbVsDOpoOa9xgUP/iDghwvjECoUNFleJc4l26sq
+Yanrhihzid4A8zgeidyR3beWoEHodffHBFL2FzbGG3ToGrsBspvKf2aqBpDB4bM
tfYnogH1/eH3kUAhurXz67JXDiULGAxF7JKu+lnYshHizl1pn0gWBTcrorOb+NSY
kKICWnGJ8pC/45Ax2/6TkpOJJzPXMWr7Jj5OaNxqMX/SMgrnA8xtUHLgE+rLuUf8
nfD9h5XEHJKhq9Z6hs7mZuF1tBPyPh5leJ0JZFW0hb+cc9VdRCgOqQijSiRCUjZP
VUpWM73BKIkoJ8BjibhMDcYKQOWNcWtqMbPNfxctR7DAhmnEpSn902o1A1rilQtL
VeQT5u9I0GdYbUhZHgAPyT7ZxTffJl+CPa/UYXL5HPBHzEajPR9ADgGPpTQ0xRC9
BEmq8URldlwFfkgsNIk39vBsQLWrt8rIpZyqlY2HNUnKyvyj8U7jFfzExzn1A+Yb
S6bU7Kftz2e0FIFmUOD6SirPX7tF5YQqBJyRPZsSMeJTcIERbejp0YLwaudfX1z8
DlS8P44sRQHYrzN4utTqTtqfbLKXcmfNYBonKgnjVDGs+dM0gtiYy5sUUmPXjEHo
czcXzUddR6GO3UDP2X0T3YWgX2ed471RP3Qkmd5uyibS8zessvZGzL3QER3Y3jxz
NAro2mMA5lQjl+GfxdvO
=ex5r
-----END PGP SIGNATURE-----

--lIrNkN/7tmsD/ALM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
