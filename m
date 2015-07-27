Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id D7CE06B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:11:33 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so39562749qkb.2
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:11:33 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id i92si21035778qge.42.2015.07.27.07.11.32
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 07:11:32 -0700 (PDT)
Date: Mon, 27 Jul 2015 10:11:31 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V5 5/7] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Message-ID: <20150727141131.GA21664@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <1437773325-8623-6-git-send-email-emunson@akamai.com>
 <20150727073129.GE11657@node.dhcp.inet.fi>
 <20150727134126.GB17133@akamai.com>
 <20150727140355.GA11360@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Content-Disposition: inline
In-Reply-To: <20150727140355.GA11360@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Paul Gortmaker <paul.gortmaker@windriver.com>, Chris Metcalf <cmetcalf@ezchip.com>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Jul 2015, Kirill A. Shutemov wrote:

> On Mon, Jul 27, 2015 at 09:41:26AM -0400, Eric B Munson wrote:
> > On Mon, 27 Jul 2015, Kirill A. Shutemov wrote:
> >=20
> > > On Fri, Jul 24, 2015 at 05:28:43PM -0400, Eric B Munson wrote:
> > > > The cost of faulting in all memory to be locked can be very high wh=
en
> > > > working with large mappings.  If only portions of the mapping will =
be
> > > > used this can incur a high penalty for locking.
> > > >=20
> > > > Now that we have the new VMA flag for the locked but not present st=
ate,
> > > > expose it as an mmap option like MAP_LOCKED -> VM_LOCKED.
> > >=20
> > > As I mentioned before, I don't think this interface is justified.
> > >=20
> > > MAP_LOCKED has known issues[1]. The MAP_LOCKED problem is not necessa=
ry
> > > affects MAP_LOCKONFAULT, but still.
> > >=20
> > > Let's not add new interface unless it's demonstrably useful.
> > >=20
> > > [1] http://lkml.kernel.org/g/20150114095019.GC4706@dhcp22.suse.cz
> >=20
> > I understand and should have been more explicit.  This patch is still
> > included becuase I have an internal user that wants to see it added.
> > The problem discussed in the thread you point out does not affect
> > MAP_LOCKONFAULT because we do not attempt to populate the region with
> > MAP_LOCKONFAULT.
> >=20
> > As I told Vlastimil, if this is a hard NAK with the patch I can work
> > with that.  Otherwise I prefer it stays.
>=20
> That's not how it works.

I am not sure what you mean here.  I have a user that will find this
useful and MAP_LOCKONFAULT does not suffer from the problem you point
out.  I do not understand your NAK but thank you for explicit about it.

>=20
> Once an ABI added to the kernel it stays there practically forever.
> Therefore it must be useful to justify maintenance cost. I don't see it
> demonstrated.

I understand this, and I get that you do not like MAP_LOCKED, but I do
not see how your dislike for MAP_LOCKED means that this would not be
useful.

>=20
> So, NAK.
>=20

V6 will not have the new mmap flag unless there is someone else that
speaks up in favor of keeping it.


--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVtjwTAAoJELbVsDOpoOa9cywQAMOd32FQcpI15XIUZk3SBUeg
/oa/5375ZFZqvbJHZn4iTFt4FxbvYUJPsAkWxH92nUQjdWBleVEUKhUs+K3tEz85
yNtsDJFuMlR07fY75oqz5LqorrMwHw1CNDXj32ADaPg+hxdPwMH9HUC2AeKIwv4E
lOhyZdUqfgLn0uYnJNhoDSqoFENCiFvX3jZsGszbfsEljPe/PfgwIJVCZP+R9p0X
oQ/u0MXGHLLOagPVFlXh3lkj8Q/C+/PiT8ubQUIdcsz//0E9mB+X7M+Za2hWtU6A
QUclnufc6+D7FGwq6zVKb5AEyDg2WVuGK/jWO44a9bAlZxVpttsGaobdQoz2Xs8r
mWZ0VQxSJIPoXFJ3ggCgJQYCQtZWOiHPfotP3w4ba6rMEP1M/AG5F7aTFEEkxPdv
wVCDab4asBJMZHRKxlyK2KX2sXclOc9eJ1BqC1EZmNjDcrxxAwoeb1+8ZjOkeOH5
S1bPWdotTfQemH6iJulJP+GVtjo0fUw1S+tpiapJu16NfiUvS2bjAczwjgu9pE1Y
LW3JC/MVfD13DVSDwHEmuIelWOlRyqsiFm86FZz2pXkocSISzESCk3otqJv8f3iN
M3xYGJIlyFxPgelUcPbkqh/G4g3+tVC4d3zhxLVfUJMUhWHZlKYr2pgNhii4Yty8
HUDKoUVYKSp1f5/jOB+f
=vq9F
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
