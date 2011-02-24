Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 735278D003A
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 13:22:28 -0500 (EST)
Received: by vxc38 with SMTP id 38so924743vxc.14
        for <linux-mm@kvack.org>; Thu, 24 Feb 2011 10:22:25 -0800 (PST)
Date: Thu, 24 Feb 2011 13:20:33 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH] hugetlbfs: correct handling of negative input to
 /proc/sys/vm/nr_hugepages
Message-ID: <20110224182033.GA30387@mgebm.net>
References: <1298303270-3184-1-git-send-email-pholasek@redhat.com>
 <20110222100235.GA15652@csn.ul.ie>
 <20110223161818.9876cc10.akpm@linux-foundation.org>
 <20110224094912.GO15652@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Content-Disposition: inline
In-Reply-To: <20110224094912.GO15652@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 24 Feb 2011, Mel Gorman wrote:

> On Wed, Feb 23, 2011 at 04:18:18PM -0800, Andrew Morton wrote:
> > On Tue, 22 Feb 2011 10:02:36 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> >=20
> > > On Mon, Feb 21, 2011 at 04:47:49PM +0100, Petr Holasek wrote:
> > > > When user insert negative value into /proc/sys/vm/nr_hugepages it w=
ill result
> > > > in the setting a random number of HugePages in system (can be easil=
y showed
> > > > at /proc/meminfo output).
> > >=20
> > > I bet you a shiny penny that the value of HugePages becomes the maxim=
um
> > > number that could be allocated by the system at the time rather than a
> > > random value.
> >=20
> > That seems to be the case from my reading.  In which case the patch
> > removes probably-undocumented and possibly-useful existing behavior.
> >=20
>=20
> It's not proof that no one does this but I'm not aware of any documentati=
on
> related to hugetlbfs that recommends writing negative values to take adva=
ntage
> of this side-effect. It's more likely they simply wrote a very large numb=
er
> to nr_hugepages if they wanted "as many hugepages as possible" as it makes
> more intuitive sense than asking for a negative amount of pages. hugeadm =
at
> least is not depending on this behaviour AFAIK.

That is correct, hugeadm never writes negative values to huge page pool siz=
es.

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNZqFxAAoJEH65iIruGRnNZFIH/ja1AgjpNu57iF4BLYANI3Q8
qYy1oerxQTil8d5488NoHVAf7qTWVmXpOTy+E0+u7VPOqsCEYQbyQVBBgUabcS8U
TX7MeijKY69l+KzEbkDGudWDnOrLMP55V6vmDSYVte4Oawi7o2qA4vmkEqmPvuvI
X7N5r7B5pjHjiVsASaWNtpw0HuWBwjnKgzUajIlyTvMN7d+tGQmYTV5wL+kRTCbC
1yfbiAdzYZ3A5nTIJbmVLzMlC2ZtCiUL9Wu9BZ6n05DEZtU06dbzSKzP4GVTmK78
GwucW/aQIrYBH6kGy4iTgDWFs6ED0+NoTZerdYa4KOXP4gxNXwPchwS+bDMFdK4=
=nHB7
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
