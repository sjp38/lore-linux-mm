Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 135CA6B0087
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 05:57:54 -0500 (EST)
Date: Wed, 12 Dec 2012 12:59:13 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/2] kernel BUG at mm/huge_memory.c:212!
Message-ID: <20121212105913.GA14379@otc-wbsnb-06>
References: <50B52E17.8020205@suse.cz>
 <1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
 <50BCA2E4.8050600@suse.cz>
 <CAA_GA1dZm7LYe46vdurFf8avbSViPeT2jC_L0A3Oejg97RsmBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Content-Disposition: inline
In-Reply-To: <CAA_GA1dZm7LYe46vdurFf8avbSViPeT2jC_L0A3Oejg97RsmBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 12, 2012 at 01:36:36PM +0800, Bob Liu wrote:
> On Mon, Dec 3, 2012 at 9:02 PM, Jiri Slaby <jslaby@suse.cz> wrote:
> > On 11/30/2012 04:03 PM, Kirill A. Shutemov wrote:
> >> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >>
> >> Hi Jiri,
> >>
> >> Sorry for late answer. It took time to reproduce and debug the issue.
> >>
> >> Could you test two patches below by thread. I expect it to fix both
> >> issues: put_huge_zero_page() and Bad rss-counter state.
> >
> > Hi, yes, since applying the patches on the last Thu, it didn't recur.
> >
> >> Kirill A. Shutemov (2):
> >>   thp: fix anononymous page accounting in fallback path for COW of HZP
> >>   thp: avoid race on multiple parallel page faults to the same page
> >>
> >>  mm/huge_memory.c | 30 +++++++++++++++++++++++++-----
> >>  1 file changed, 25 insertions(+), 5 deletions(-)
> >
>=20
> I still saw this bug on 3.7.0-rc8, but it's hard to reproduce it.
> It appears only once.

I guess the patch you've posted fixes the issue, right?

It's useful to enable debug_cow to test fallback path:

echo 1 > /sys/kernel/mm/transparent_hugepage/debug_cow

--=20
 Kirill A. Shutemov

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQyGOBAAoJEAd+omnVudOMFXsQAJb3ToTDx5030zT7udfoM2a7
kx1lNi/pvufv/C/h09nVN0VYZIQ51TZT16b6/8gPw640E8/0I7GQy6J6e56JImxL
ZsuXWp0vCOUZMSB1CKg8tRDLCbcqr/wCtuonIrRifC1jDzyW/QCVLaX03focMrgB
6lIbSu3ZebBukh0STD0hU+/dW4jW1JUyR0FOYNwXJoCNTTx8x7Nhw7VwdlEX2x6Z
+ajEuDcFDX3OrljIaD1YeeJLercpzH1uqzxSFo8ifoyqs4aQTTM7dgL2agfu5swu
T/2KPA3WbGcRGlBl0+iuIrk1o8sX3SL+CVFp5ZZrXTSD0AOLw1E6sJ/QOfAq4SoH
BQP1OTQgobePvRWmj+iaqHhJa6yid7YAWBTO+SCVLKY5B07WcvYN/uSMrxNVcnWN
jH+PKBcUELNp2CoNlW7IMutRL8qtf1MuoIrekmDvpKhLgax8kdq7G8KaHCRlRKBs
l/Kn5QUp1a2/12gUBD2iMRaBSTMS+SDSdvPWrwfGueqjSFhJ1NrwYpSHu5VSR50z
qX9DcCWijMWp0f07PhXFeYD+YQ7PyIjSqiqvzvBPHvsckfBC03ltXneDCcdxeoAS
qTIY87rtP8pqlZ8F9+ivJC1eUmG+doMWlsE0xy8Am71Bw0hGoKMoYgIWpIPrZTQo
5uwFe82ExxDqce567OoP
=9kdx
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
