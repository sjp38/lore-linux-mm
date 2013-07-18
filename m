Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9FF566B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 13:36:51 -0400 (EDT)
Subject: Re: zswap: How to determine whether it is compressing swap pages?
In-Reply-To: Your message of "Thu, 18 Jul 2013 20:43:40 +0800."
             <51E7E2FC.3070807@oracle.com>
From: Valdis.Kletnieks@vt.edu
References: <1674223.HVFdAhB7u5@merkaba> <3337744.IgTT2hGPE5@merkaba> <20130717143834.GA4379@variantweb.net> <3125575.Ki4S75m1kx@merkaba>
            <51E7E2FC.3070807@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1374169009_1526P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Jul 2013 13:36:49 -0400
Message-ID: <4360.1374169009@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Martin Steigerwald <Martin@lichtvoll.de>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1374169009_1526P
Content-Type: text/plain; charset=us-ascii

On Thu, 18 Jul 2013 20:43:40 +0800, Bob Liu said:

> Could you make some test by kernel compiling? Something like kernbench.
> During my testing, I found that the swap ins/outs operations reduced but
> the kernel compile time didn't reduce accordingly.

If your kernel source tree is cache-cold, the swap in/out activity is
probably hidden and ahrd to notice among all the disk I/O to read the source in.

--==_Exmh_1374169009_1526P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUegnsAdmEQWDXROgAQIqJRAAn4jRug+VnfFEQCTMk0FjWCv5ivgBIPAU
gxVe9WVW+kqWr9NAv8mDdVu4Mxwq/DMcfb3suXMCDl0mM/5jZjN8skuOqzQ4p6vi
/3/STXQ4ec8AAYo6mO1Mn2BVN8CGi3mp+kDWvq4DqUgI3fUBlySPerAHH/jV/u5G
QRgNGyKOD0s40RPC+VGdAP0RF6wjM9Y13TrED7c0U8OLuO+MMMN9kkKvTT/5X4lY
XLu9u55+RU80QMvSCRlBbz2UA9AQcoQKwciNuWSrDqdGFOTO9UPNc9MYAfLL2zg+
f96voPLQ/TxO+xIhkuCOd4BaxEySV/rwGazqQ6LXqekRv/4hHAqXshu1iqneu14w
cf6DaUekN8NzWRTFeHcWVCekhO3WVfem9HYsP7SekwdWQ9cXbWuEtOh/myBNBL7Q
e7AbaLuYTu79R+QC+mCnRDpYoIxpQGiK2L/RfS5lh2jRZ5CsTt3OC6Wb93+S8Cij
mzu8Ymq/uOtfCyDP6p2cOFsDP3fYd3S+xH0ofxzTzVeER4yacIeA5sysqL4UfD3A
52Ak56g7iWxB4JxqcA1KmLe6a8950xbvAQOPqc3fCafquSYvZwA7iA7RwDCPeAoW
R2ehZ/Tw+lm4XuE507dc+5v4oyZzfE29vYeF+dTINiMYWKWvK26AaVTWOzbt1Pwt
7JMMGPZDSm0=
=fe7g
-----END PGP SIGNATURE-----

--==_Exmh_1374169009_1526P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
