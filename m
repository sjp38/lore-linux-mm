Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id EB4386B009C
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:51:35 -0500 (EST)
Date: Tue, 11 Dec 2012 10:53:00 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH, REBASED] asm-generic, mm: PTE_SPECIAL cleanup
Message-ID: <20121211085300.GA32158@otc-wbsnb-06>
References: <1354881321-29363-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20121207143002.GB21233@arm.com>
 <20121207144112.GA17044@otc-wbsnb-06>
 <20121207123517.3fc93a34.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Content-Disposition: inline
In-Reply-To: <20121207123517.3fc93a34.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 07, 2012 at 12:35:17PM -0800, Andrew Morton wrote:
> On Fri, 7 Dec 2012 16:41:12 +0200
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > Advertise PTE_SPECIAL through Kconfig option and consolidate dummy
> > pte_special() and mkspecial() in <asm-generic/pgtable.h>
>=20
> why?

Just drop some amount of useless code. Do you think it's not reasonable?

--=20
 Kirill A. Shutemov

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQxvRsAAoJEAd+omnVudOM8VsQAMu4u0bNE9Xv2f+RP68lYcZg
NkjQFvNws7vYZjv3xtKN1kssbP4EF1WYU5XeV03vWla4+FJ6xnSAL/fq1MMXiLH/
Id6iKjl2EwwxGY3jcGA8U6/6STszdvSg3ee4imsgVdpH9eYelsE8rqDD3BVF6Et2
QS6i0iNmWyayvLE6jbwVl9/qR16QYraXMobjKEYe4aeWTlZGTqhgMQtbhm7K/heV
3OVGHetiq+MOdr7KJYb+YZc/81kd6sMXDpEafyQlhdIHF8AMYVQA2Pm2AwvA0/RC
CCZdGXd8J1jIetIcbJknp5Cg7pB5uEAVcNFGwPoa8i+LmRc74yNvqEg/KsyDJd3a
NhPST97tzPss0VZGkX0A3P34d4jMIihEW7WOTXtgm0MjrGdOGWy7yAearmWTgtS+
MEqul5QCmHf6te2if2ZUcOeJyRDcuDKPrnkjHS1CJSei2HuWSk7UQJd34uXil0m1
BAD4+yWH+eR2ELTxsTljERlgombPETMkoZ2lP3ty5VWoH4k9DuNQ1QCyxoKem4hA
0K3eanwMTNyz4nM1R5P21tzyGl9xwPJpyqZWNtQDhwn9qSKuIcrPQ5C45wBFFPky
rQwqIHnMaquOUnbn+n7nrvvBzaeIp9xU6r1J86Ioza164q3aJQN1BRgx0Cfr1anc
j7ojFfbWzkeJBbs4m4kr
=mtam
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
