Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id C4C2B6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:16:40 -0400 (EDT)
Received: by qcet6 with SMTP id t6so21071395qce.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 07:16:40 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id 128si29426132qhs.23.2015.06.25.07.16.39
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 07:16:39 -0700 (PDT)
Date: Thu, 25 Jun 2015 10:16:38 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH V2 0/3] Allow user to request memory to be locked
 on page fault
Message-ID: <20150625141638.GF2329@akamai.com>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <20150610145929.b22be8647887ea7091b09ae1@linux-foundation.org>
 <5579DFBA.80809@akamai.com>
 <20150611123424.4bb07cffd0e5bb146cc92231@linux-foundation.org>
 <557ACAFC.90608@suse.cz>
 <20150615144356.GB12300@akamai.com>
 <55895956.5020707@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gneEPciiIl/aKvOT"
Content-Disposition: inline
In-Reply-To: <55895956.5020707@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--gneEPciiIl/aKvOT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 23 Jun 2015, Vlastimil Babka wrote:

> On 06/15/2015 04:43 PM, Eric B Munson wrote:
> >>Note that the semantic of MAP_LOCKED can be subtly surprising:
> >>
> >>"mlock(2) fails if the memory range cannot get populated to guarantee
> >>that no future major faults will happen on the range.
> >>mmap(MAP_LOCKED) on the other hand silently succeeds even if the
> >>range was populated only
> >>partially."
> >>
> >>( from http://marc.info/?l=3Dlinux-mm&m=3D143152790412727&w=3D2 )
> >>
> >>So MAP_LOCKED can silently behave like MAP_LOCKONFAULT. While
> >>MAP_LOCKONFAULT doesn't suffer from such problem, I wonder if that's
> >>sufficient reason not to extend mmap by new mlock() flags that can
> >>be instead applied to the VMA after mmapping, using the proposed
> >>mlock2() with flags. So I think instead we could deprecate
> >>MAP_LOCKED more prominently. I doubt the overhead of calling the
> >>extra syscall matters here?
> >
> >We could talk about retiring the MAP_LOCKED flag but I suspect that
> >would get significantly more pushback than adding a new mmap flag.
>=20
> Oh no we can't "retire" as in remove the flag, ever. Just not
> continue the way of mmap() flags related to mlock().
>=20
> >Likely that the overhead does not matter in most cases, but presumably
> >there are cases where it does (as we have a MAP_LOCKED flag today).
> >Even with the proposed new system calls I think we should have the
> >MAP_LOCKONFAULT for parity with MAP_LOCKED.
>=20
> I'm not convinced, but it's not a major issue.
>=20
> >>
> >>>- mlock() takes a `flags' argument.  Presently that's
> >>>   MLOCK_LOCKED|MLOCK_LOCKONFAULT.
> >>>
> >>>- munlock() takes a `flags' arument.  MLOCK_LOCKED|MLOCK_LOCKONFAULT
> >>>   to specify which flags are being cleared.
> >>>
> >>>- mlockall() and munlockall() ditto.
> >>>
> >>>
> >>>IOW, LOCKED and LOCKEDONFAULT are treated identically and independentl=
y.
> >>>
> >>>Now, that's how we would have designed all this on day one.  And I
> >>>think we can do this now, by adding new mlock2() and munlock2()
> >>>syscalls.  And we may as well deprecate the old mlock() and munlock(),
> >>>not that this matters much.
> >>>
> >>>*should* we do this?  I'm thinking "yes" - it's all pretty simple
> >>>boilerplate and wrappers and such, and it gets the interface correct,
> >>>and extensible.
> >>
> >>If the new LOCKONFAULT functionality is indeed desired (I haven't
> >>still decided myself) then I agree that would be the cleanest way.
> >
> >Do you disagree with the use cases I have listed or do you think there
> >is a better way of addressing those cases?
>=20
> I'm somewhat sceptical about the security one. Are security
> sensitive buffers that large to matter? The performance one is more
> convincing and I don't see a better way, so OK.

They can be, the two that come to mind are medical images and high
resolution sensor data.

>=20
> >
> >>
> >>>What do others think?
>=20

--gneEPciiIl/aKvOT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVjA1GAAoJELbVsDOpoOa9UuYP/0uK/Rd97QRrj7JihySL0bIp
xR5VEgBq3dvL9zso97dWMfg427XMFyEk6ZmPzMCic6uaNOXj2wj95fMH8/JZLlGP
VDwj+tVXUrS4cSYMlf2KoJnZE3lAU4Qjhef/B50FOd+QfnP3m7j78SeBQLefUyBF
dh6NnpZyzqChIQsDS3j9Qy9BlUH4JRuKW5AGLbEIPrl7DdN1YqZ3h5czy3ouEN6N
8xi145ThIaNAlEmdpNmTcEwAFQpTnX9F8B3Zi9+oPsgNvd6yb6v5ZWlxd+pdxGwn
GzNpU6iPrWjgm62NaRlZieLP39fL+UwIZ4wijKQjCV8uHYLaCF+edchj2tX5tV1+
K1C7Vt4SJrz/xdgfT2uXiGK7/fu2ti6jO5Vl1fdGSPmskpqlpRsUsQs9igjW0uH8
neYV9mS1H7XhbMAfXsEiMjKNyY2X5o3+085dtwnhUG28v/PJob7AnP20DuAAzsQF
h9sKslrlgctv2pS0ATCEj/ZrO7OheNq72YEcUhIfCgwF/5bG4PNuNmlzmpYdMmE2
skMlXEkc6x+nc0K5D61tjTfRcIX9nILAVyWb/FdU//OLSEEPlexCyOOPnsyFPyLA
RLHPLoIE4qnFMemYtw3QiXr1XwJZ260HIQRl/x7Qx4ppceRkXmmhbNrlMud2Ru0z
TgY/kWkb2P90kkXjd2qQ
=ayiS
-----END PGP SIGNATURE-----

--gneEPciiIl/aKvOT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
