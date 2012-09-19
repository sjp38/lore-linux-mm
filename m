Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4282C6B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 21:36:52 -0400 (EDT)
Date: Wed, 19 Sep 2012 11:36:40 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: qemu-kvm loops after kernel udpate
Message-Id: <20120919113640.376b4061d3169d296b68ab92@canb.auug.org.au>
In-Reply-To: <20120918172029.b5425a40.akpm@linux-foundation.org>
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
	<20120919100034.ceaee306e24e00cdf6f1e92e@canb.auug.org.au>
	<20120918172029.b5425a40.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__19_Sep_2012_11_36_40_+1000_ke6.Te4Vl9z3KMfT"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Avi Kivity <avi@redhat.com>, Jiri Slaby <jirislaby@gmail.com>, Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Haggai Eran <haggaie@mellanox.com>, linux-mm@kvack.org, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

--Signature=_Wed__19_Sep_2012_11_36_40_+1000_ke6.Te4Vl9z3KMfT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Tue, 18 Sep 2012 17:20:29 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Wed, 19 Sep 2012 10:00:34 +1000 Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
>=20
> > On Tue, 18 Sep 2012 12:46:46 -0700 Andrew Morton <akpm@linux-foundation=
.org> wrote:
> > >
> > > hm, thanks.  This will probably take some time to resolve so I think
> > > I'll drop
> > >=20
> > > mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock.p=
atch
> > > mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-f=
ix.patch
> > > mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-f=
ix-fix.patch
> > > mm-wrap-calls-to-set_pte_at_notify-with-invalidate_range_start-and-in=
validate_range_end.patch
> >=20
> > Should I attempt to remove these from the akpm tree in linux-next today?
>=20
> That would be best - there's no point in having people test (and debug)
> dead stuff.

OK, I removed them.

> > Or should I just wait for a new mmotm?
>=20
> You could be brave and test http://ozlabs.org/~akpm/mmots/ for me :)

Brave? maybe.  Stupid? no :-)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__19_Sep_2012_11_36_40_+1000_ke6.Te4Vl9z3KMfT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQWSGoAAoJEECxmPOUX5FE6cIQAJVkJuS1VpdQs4CuEtAwiuZF
2i4LhIRSnH2srOR/aL9LoJARUelCe2Bcnj/HkuhFuEH/k6rCbP5xW3ulZvCFZl3S
2YWQn8UXcZwHExnZf8mPosiZQhn016JDo1OVRqtglrR2CJxAmKfvcJXKiiTdx78a
JkU2LhdmnsffFh2+/6YbIcV13qiCnl+ioTNbDGsjkoi5zZY+zjgGrh8nWi+6Og2a
vaBE2DzUWx8vWrbJvlLK3+mjQCbk/0H6IIoV1CSoxPdVwXw4lnbcuqGTPhDSaab9
MD8HGoWlD7TS2RcIv/WnaTj/8n3A5zV6tB+hfUWaLugEQwW2qK+onbs1LzAl2v9x
pvrfWMgfJBDyGE0+t3mFPnF09/4mq0oN9ibepcu7Z36rhpfjZed9a6/NTTDTawnO
Xa7LnYNmZsafyHNSLCInL1cGMz1iep5a9j6grAf1aUjfW1AngS+G9rju5AH79QGd
qePXL3oZMmXrCUaxzQbt8y/xNt+glazAa1BklxkSu8ywQIqvjLr0M54helM4InY8
PKKj73lJQVMmlYeB7BvQi/669SgAWVP1olXMh2pdHj0yBsrSnxCkbE+p1cIzePbh
ic8FXz9FxskQyhGncfwAgUqLH31Cp93ll48nUL1F/ELKOqAD0nj3PQsS6EKtygGf
DUGWn37CDD67wQ4e5dON
=IU+z
-----END PGP SIGNATURE-----

--Signature=_Wed__19_Sep_2012_11_36_40_+1000_ke6.Te4Vl9z3KMfT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
