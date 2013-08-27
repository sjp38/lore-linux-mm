Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 07C716B0068
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 03:49:04 -0400 (EDT)
Date: Tue, 27 Aug 2013 03:37:01 -0400
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Message-ID: <20130827073701.GA23035@gchen.bj.intel.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
 <521c1f3f.813d320a.6ba7.5a17SMTPIN_ADDED_BROKEN@mx.google.com>
 <1377574896-5k1diwl4-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Content-Disposition: inline
In-Reply-To: <1377574896-5k1diwl4-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 26, 2013 at 11:41:36PM -0400, Naoya Horiguchi wrote:
> Date: Mon, 26 Aug 2013 23:41:36 -0400
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen
>  <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck
>  <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org,
>  linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of
>  madvise_hwpoison
> User-Agent: Mutt 1.5.21 (2010-09-15)
>=20
> On Tue, Aug 27, 2013 at 11:38:27AM +0800, Wanpeng Li wrote:
> > Hi Naoya,
> > On Mon, Aug 26, 2013 at 11:28:16PM -0400, Naoya Horiguchi wrote:
> > >On Tue, Aug 27, 2013 at 10:39:31AM +0800, Wanpeng Li wrote:
> > >> The return value outside for loop is always zero which means madvise=
_hwpoison=20
> > >> return success, however, this is not truth for soft_offline_page w/ =
failure
> > >> return value.
> > >
> > >I don't understand what you want to do for what reason. Could you clar=
ify
> > >those?
> >=20
> > int ret is defined in two place in madvise_hwpoison. One is out of for
> > loop and its value is always zero(zero means success for madvise), the=
=20
> > other one is in for loop. The soft_offline_page function maybe return=
=20
> > -EBUSY and break, however, the ret out of for loop is return which mean=
s=20
> > madvise_hwpoison success.=20
>=20
> Oh, I see. Thanks.
>=20
I don't think such change is a good idea. The original code is obviously
easy to confuse people. Why not removing redundant local variable?


--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSHFcdAAoJEI01n1+kOSLHTbYP/R/a1ImSf2zyC3hd41apzJc0
cLpn4+TgZeXT7Fj49PgyNCEOaQP7HUfAJko2wzSGkILWwouj3cmC9nSofGsDpZkk
4mMnEAuVbLC0CasrgJoFdH75WenRT1RWE/kAEqsRnloUsDK/i3rVCeRe36KC6Qzv
R0meh0aWnkywA4L8kUo+/QoqpIfvr9kNgdahfjXqN9FEFN6X30IOSNkKO3+UP2c9
OJDWjdMco9svzgXKQysI3geYAUomy0G0qSC25or7E//Bym6boFhzWfU6Hg+aNu9a
AT+WR2JfWx6K+m5dFs0M0jnF1AroTN5sGPBxXoIVVCItuF9QVwPnoep9rSa1Zpd0
xgpzqzQdTsq+1e7a5K7IyOMNn/0G/YPl6hMD2xqOZ9hws64ccbtKDrYXACrxucJ4
9DnCxoJQW/7ZXeETAOcF4NmWBSsS9Qg2e927OVxAu+AHG1M+U/WvRoAbRF51ks1G
yyp5DobqhBK5YrduM2RPZR1OMcfURBUitBOlW7nnza1rNdh0SjYSsBrcef7LjAcK
IYNlIACQ7ClMhsC5JaeyvE59tAZ3vnU/4M9uMH00zAlS81GwNVMK1gnrO+kvFd+d
j4ban8J+xRDQoOrLFZ5d9eeVyZPwt2g18xCHwVuGeEJqXDXVDOg8+zATFE6oYABu
tysHTdCwapZm3O5g3jaJ
=pD/o
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
