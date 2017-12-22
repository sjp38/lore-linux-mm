Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 663F66B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 21:51:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w141so4797060wme.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 18:51:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l60sor12557159edl.14.2017.12.21.18.51.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 18:51:11 -0800 (PST)
Date: Fri, 22 Dec 2017 10:53:28 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v2 1/1] Move kfree_call_rcu() to slab_common.c
Message-ID: <20171222025328.GF9516@tardis>
References: <1513895570-28640-1-git-send-email-rao.shoaib@oracle.com>
 <20171222011704.GD1044@tardis>
 <20171222014212.GB7829@linux.vnet.ibm.com>
 <20171222023846.GE9516@tardis>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qp4W5+cUSnZs0RIF"
Content-Disposition: inline
In-Reply-To: <20171222023846.GE9516@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: rao.shoaib@oracle.com, brouer@redhat.com, linux-mm@kvack.org


--qp4W5+cUSnZs0RIF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 22, 2017 at 10:38:46AM +0800, Boqun Feng wrote:
> On Thu, Dec 21, 2017 at 05:42:12PM -0800, Paul E. McKenney wrote:
> > On Fri, Dec 22, 2017 at 09:17:04AM +0800, Boqun Feng wrote:
> > > Hi Shoaib,
> > >=20
> > > On Thu, Dec 21, 2017 at 02:32:50PM -0800, rao.shoaib@oracle.com wrote:
> > > > From: Rao Shoaib <rao.shoaib@oracle.com>
> > > >=20
> > > > This patch moves kfree_call_rcu() and related macros out of rcu cod=
e.
> > > > A new function call_rcu_lazy() is created for calling __call_rcu() =
with
> > > > the lazy flag. kfree_call_rcu() in the tiny implementation remains =
unchanged.
> > > >=20
> > >=20
> > > Mind to explain why you want to do this in the commit log?
> >=20
> > I am too close to this one, so I need you guys to hash this out.  ;-)
> >=20
>=20
> I think simply improving the modularity is OK, but it's better to have
> some words in the commit log ;-)
>=20

Hmm.. seems like this is first part of the split version for:

	https://lkml.kernel.org/r/1513705948-31072-1-git-send-email-rao.shoaib@ora=
cle.com

In that case, Shoaib, I think you'd better send the whole thing as a
proper patchset(which is a set of patches) and write a cover letter.

Feel free to ask questions ;-)

Regards,
Boqun

[...]

--qp4W5+cUSnZs0RIF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlo8c6UACgkQSXnow7UH
+rgzxAgAiTUQDFuyVdnMrBtt4XifXQZnbWe+/0uZhOVaMPG0P3t4sanFfeD/g74L
yNDUlPzfFsnG08NO4UjnE45BTvlUGwSUyi29d3ZLvkUZcXyojjguGaOjE/Mse8cS
c8wg1Z9co+LuGhUb4pIHW6Zikd+5LR0yOf68FqeNNnHhnn3+DCPPIB703PWISRv1
k2Sv0j6C3kGG/uX+AiGTLuwviQ/GpE0eAV7+66av8qDM9cZ8k7DXbGzGnZftyx02
yu4h0ytGcuyu5Phx0SEJZ5n6IGQsJkq3AB5BjAKUuYmicbjkiwe/+HX1hHFGMB8r
78i71gGC1VWIytJNalas81CKEuRvVg==
=1Oy3
-----END PGP SIGNATURE-----

--qp4W5+cUSnZs0RIF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
