Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id EB1966B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 20:00:49 -0400 (EDT)
Date: Wed, 19 Sep 2012 10:00:34 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: qemu-kvm loops after kernel udpate
Message-Id: <20120919100034.ceaee306e24e00cdf6f1e92e@canb.auug.org.au>
In-Reply-To: <20120918124646.02aaee4f.akpm@linux-foundation.org>
References: <504F7ED8.1030702@suse.cz>
	<20120911190303.GA3626@amt.cnet>
	<504F93F1.2060005@suse.cz>
	<50504299.2050205@redhat.com>
	<50504439.3050700@suse.cz>
	<5050453B.6040702@redhat.com>
	<5050D048.4010704@suse.cz>
	<5051AE8B.7090904@redhat.com>
	<5058CE2F.7030302@suse.cz>
	<20120918124646.02aaee4f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__19_Sep_2012_10_00_34_+1000_uc+_0H1uZfS_.Vln"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Avi Kivity <avi@redhat.com>, Jiri Slaby <jirislaby@gmail.com>, Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Haggai Eran <haggaie@mellanox.com>, linux-mm@kvack.org, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

--Signature=_Wed__19_Sep_2012_10_00_34_+1000_uc+_0H1uZfS_.Vln
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Tue, 18 Sep 2012 12:46:46 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> hm, thanks.  This will probably take some time to resolve so I think
> I'll drop
>=20
> mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock.patch
> mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix.p=
atch
> mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix-f=
ix.patch
> mm-wrap-calls-to-set_pte_at_notify-with-invalidate_range_start-and-invali=
date_range_end.patch

Should I attempt to remove these from the akpm tree in linux-next today?
Or should I just wait for a new mmotm?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__19_Sep_2012_10_00_34_+1000_uc+_0H1uZfS_.Vln
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQWQsiAAoJEECxmPOUX5FEFVcP/iYZ7jzsrAtWazgRuu17ijeo
Sgnwd/Cn3zPirVmMSV/j8hWZ4vSxZ5LTRG5N3bs9Qzjl4eH5/ZvjEYP/ymFTBBss
6EVACwRLc8FEiiDk882LUwvthJnuc69KyJgGPhiX5kiUp/WiVwtMy+NFUFXLsS6f
19rm+WThxcm/27KmNiQOLqUO8O8DdFbItuCtA5PXxZGy8r1bjMsLgqgKPNYDTFu1
NnqI69zENZywOo4JqKGIDJGraoO3w4KPoDTYvbNgxACJ5wZ9ocRV6xMXuuhiXc4Q
TsXwXi4n4HxBwpHoBLag3VZ4ftlNI6rejcfpksz7jzHZndWJ3TxzRmOAiz/EBFye
4lYBZX1m6mDG5EtIQ918lf1StQySyhFSTS1+YHumtFGwf/TnKrEMveIzUgRfkvB4
IYZtbrUHYyep27+1VqDVDIFUZUCIjtwaerQmFYgfoOfRqFoIr4KTVTtlYHs84sh1
zB23Xtn67pKwdlB377nOmKU+Iog3XHRLN3SekBTBcaJ/Q9D4EEiSY5ubikcB3pB3
nu3NjzFmbgJB/y3uuE4EciD8wVDUB8R++phYXO/ZJ+O4L8oYuy6FeklZO7ZT5qsf
zAOMppLhVpmKSnSZh/utIeyqB6hcz4OY/In5Uf8vOEsjQqdYSZERcVlfG+nhGUYw
yrNJyursnYet7pMzNz6B
=xfy/
-----END PGP SIGNATURE-----

--Signature=_Wed__19_Sep_2012_10_00_34_+1000_uc+_0H1uZfS_.Vln--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
