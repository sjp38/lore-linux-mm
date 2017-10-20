Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17CD36B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:38:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n89so9281733pfk.17
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:38:38 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u9si366915plz.76.2017.10.20.01.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 01:38:37 -0700 (PDT)
Date: Fri, 20 Oct 2017 16:31:42 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171020083142.GA18017@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
 <20171017102052.ltc2lb6r7kloazgs@dhcp22.suse.cz>
 <20171018110026.GA4352@intel.com>
 <20171019124931.p5zdvs2kdwu73mwh@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <20171019124931.p5zdvs2kdwu73mwh@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Du, Changbin" <changbin.du@intel.com>, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Hocko,
On Thu, Oct 19, 2017 at 02:49:31PM +0200, Michal Hocko wrote:
> On Wed 18-10-17 19:00:26, Du, Changbin wrote:
> > Hi Hocko,
> >=20
> > On Tue, Oct 17, 2017 at 12:20:52PM +0200, Michal Hocko wrote:
> > > [CC Kirill]
> > >=20
> > > On Mon 16-10-17 17:19:16, changbin.du@intel.com wrote:
> > > > From: Changbin Du <changbin.du@intel.com>
> > > >=20
> > > > This patch introduced 4 new interfaces to allocate a prepared
> > > > transparent huge page.
> > > >   - alloc_transhuge_page_vma
> > > >   - alloc_transhuge_page_nodemask
> > > >   - alloc_transhuge_page_node
> > > >   - alloc_transhuge_page
> > > >=20
> > > > The aim is to remove duplicated code and simplify transparent
> > > > huge page allocation. These are similar to alloc_hugepage_xxx
> > > > which are for hugetlbfs pages. This patch does below changes:
> > > >   - define alloc_transhuge_page_xxx interfaces
> > > >   - apply them to all existing code
> > > >   - declare prep_transhuge_page as static since no others use it
> > > >   - remove alloc_hugepage_vma definition since it no longer has use=
rs
> > >=20
> > > So what exactly is the advantage of the new API? The diffstat doesn't
> > > sound very convincing to me.
> > >
> > The caller only need one step to allocate thp. Several LOCs removed for=
 all the
> > caller side with this change. So it's little more convinent.
>=20
> Yeah, but the overall result is more code. So I am not really convinced.=
=20
Yes, but some of code are just to make compiler happy (declarations). These=
 are
just simple light wrappers same as other functions in kernel. At least the =
code
readbility is improved by this, two steps allocation merged into one so
duplicated logic removed.

> --=20
> Michal Hocko
> SUSE Labs

--=20
Thanks,
Changbin Du

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ6bRuAAoJEAanuZwLnPNUuToH/1uns9QTLOZpMD5Bvubzc34e
72GQi2wUDwqXSWfFD5AP99SPayuh36o8vXRgCdb0ZCl+HMBcuU1aMZ6JqMu8Q781
4J8bKPUVpLykZbM3iRNRp993y7vWtHaWY0m5rEO5fofA/V5vKpWWCNqNgoQSvM/O
d1v/4VMoQ9v8Y6G2BjYzWwdlv9XpSLyGPrnRp8Ohw21lGRIq8MPdilWOZlnSd7QM
VCGPinGe0qCnCFaQtI+ZB9blxq4Ilbgq/ZAiX1WUMPNAmTdi7OF5GKxJoLquoc3y
MJaWE73z/FC/UqGjDK9nw9IsXWjoCAF9Ugt9mlnTV/4H6S4lUJoFryDx1XFgG4o=
=IH9z
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
