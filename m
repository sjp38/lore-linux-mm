Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C4F16B0088
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 12:21:26 -0500 (EST)
Received: by pwj8 with SMTP id 8so2480381pwj.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 09:21:24 -0800 (PST)
Date: Tue, 4 Jan 2011 10:21:18 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
Message-ID: <20110104172118.GB3190@mgebm.net>
References: <20110104095641.GA8651@tiehlicka.suse.cz>
 <1343872597.121624.1294136506889.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CUfgB8w4ZwR/yMy5"
Content-Disposition: inline
In-Reply-To: <1343872597.121624.1294136506889.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 04 Jan 2011, CAI Qian wrote:

>=20
> > > 3) overcommit 2gb hugepages.
> > > mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED,
> > > 3, 0) =3D -1 ENOMEM (Cannot allocate memory)
> >=20
> > Hmm, you are trying to reserve/mmap a lot of memory (17179869182 1GB
> > huge pages).
> That is strange - the test code merely did this,
> addr =3D mmap(ADDR, 2<<30, PROTECTION, FLAGS, fd, 0);
>=20
> Do you know if overcommit was designed for 1GB pages? At least, read this
> from Documentation/kernel-parameters.txt,
>=20
> hugepagesz=3D
>               ...
>              Note that 1GB pages can only be allocated at boot time
>              using hugepages=3D and not freed afterwards.
>=20
> How does it allow to be overcommitted for only being able to allocate at
> boot time?

It does not, huge page sizes that have to be allocated at boot can not be
overcommitted as the pool size cannot change after boot.
>=20
> > > Also, nr_overcommit_hugepages was overwritten with such a strange
> > > value after overcommit failure. Should we just remove this file from
> > > sysfs for simplicity?

I don't think having pagesize+arch specific logic here is going to scale (we
would need to check for 16GB pages on ppc64 as well because they have the s=
ame
restrictions as 1GB pages on x86_64) but 1GB pages might be fine to overcom=
mit
on ia64.  Perhaps the documentation needs to change to call this out specif=
ically.

> >=20
> > This is strange. The value is set only in hugetlb_overcommit_handler
> > which is a sysctl handler.
> >=20
> > Are you sure that you are not changing the value by the /sys interface
> > somewhere (there is no check for the value so you can set what-ever
> > value you like)? I fail to see any mmap code path which would change
> > this value.
> I could double-check here, but it is not important if the fact is that
> overcommit is not supported for 1GB pages.
>=20
> > Btw. which kernel version are you using.
> mmotm 2010-12-02-16-34 version 2.6.37-rc4-mm1+. This problem is also pres=
ent
> in 2.6.18.
>=20
> Thanks.
>=20
> CAI Qian
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20

--CUfgB8w4ZwR/yMy5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNI1cOAAoJEH65iIruGRnN6F0H/jQT+dZ+q7PeoMhWNiQ32sgP
ncs73Tohj7GxN3abVb6wxqvxWryl/rFHY6BSKJYyGTv1WHiVshadE67zFqC3sO1T
LZ4yGAEq0eo9ynbuousi6QqZJszONUXKoPsGPdtyWimBnyitVxjFbbNdkeyIQbLA
6glFOqJC1lxwcrkzFY4pWzVT8VUUWTg9JbP4Mhkqbse7Sv2P7xFkP+oMliwXlvwY
X+q/4QIupdgVNDLoKKhVvwMx/EcTBgoL/EgWhpJP4Ws4bFVyCwOWVDmND7Cl0R3q
5Ntst6QzUceGju6f8FVEEeyxXwF1dodUGD5ts1YDHN2rs/Om+Iu6AsHqPqebZGk=
=kW7A
-----END PGP SIGNATURE-----

--CUfgB8w4ZwR/yMy5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
