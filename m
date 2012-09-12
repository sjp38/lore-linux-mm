Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 9F3816B00B2
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 06:09:22 -0400 (EDT)
Date: Wed, 12 Sep 2012 13:09:41 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 0/8] Avoid cache trashing on clearing huge/gigantic
 page
Message-ID: <20120912100941.GA26582@otc-wbsnb-06>
References: <1345470757-12005-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
In-Reply-To: <1345470757-12005-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Any feedback?

--=20
 Kirill A. Shutemov

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQUF9lAAoJEAd+omnVudOMqvgP/A9oBD+NU+NuFlm6b32IkUIR
2jlEFuSzAp3dAS+aQWVcjLz88pNu7ZjD2m9dTWwVr03UKSlfc/UUcHctWmjrhj+B
trkuGQ7qVadFTaunqj1z1NZGCrXwGTdw2f+soGtJ+cmwmOqxrqyDJlbJyyOfpiJe
iYyOU522V7Rc/cnyjY+OxOkaHDBy3RIpo6DhVpSC4Ws6wH6bkuiM2ZYAx+fiRDnj
Ii60Iel88rjQ0uSeTQ+Jznu16czL4q4bRB9IeT24jUQRgTp7kYKNyjzgy4/zrjOL
Dlkck9VihPQhZ3QxAjqcxQQCwclB0GctZDFUIrP97+REFlvd3u7yVzgxpeVuqtsz
K6aXJDcPqfTGyEe0OgOGVb+M6ylvIvsXjNXkym85PTCZNnw9smem1S2HY5689bH+
ELP9ruYagr1yb+LTX3CQmFuvmoCyuzES/tgw97AJbFP3prkt0K44WhBsJCaflJjl
efJg6qWTwTrIK8hq0ulcWnwa2oi9zbNwV2SVgDdVQmOfwtzKAp69ijF0Rd4lwpZf
47ch8oZDVcn8Fv2nhv9FrFr8JiAZ07eIwzeAGiSfpIRpcKXoKUp8y950i++mlxNq
xoGPDY1odKCKoVsbwYtW/E9l/tmUhTljqExfn9pzcHqMz4YUMGob7xnZOP0ljY5y
ikNOztWkQPhLD2Cj1nLx
=p8ME
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
