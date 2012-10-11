Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7826A6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:57:23 -0400 (EDT)
Subject: Re: kswapd0: wxcessive CPU usage
In-Reply-To: Your message of "Thu, 11 Oct 2012 17:34:24 +0200."
             <5076E700.2030909@suse.cz>
From: Valdis.Kletnieks@vt.edu
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu>
            <5076E700.2030909@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1349978211_1985P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Oct 2012 13:56:51 -0400
Message-ID: <118079.1349978211@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>

--==_Exmh_1349978211_1985P
Content-Type: text/plain; charset=us-ascii

On Thu, 11 Oct 2012 17:34:24 +0200, Jiri Slaby said:
> On 10/11/2012 03:44 PM, Valdis.Kletnieks@vt.edu wrote:
> > So at least we know we're not hallucinating. :)
>
> Just a thought? Do you have raid?

Nope, just a 160G laptop spinning hard drive. Filesystems are
ext4 on LVM on a cryptoLUKS partition on /dev/sda2.

--==_Exmh_1349978211_1985P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUHcIYwdmEQWDXROgAQJyShAAgujgX/Bqb0muTiM7zQML12rouyjrzGJ9
IrOmR/ckASQiO7mYpGJscQYv/jGSYB248K9ethpm/4lMFuRj/1vXv3se7jhzuwzG
lBa7CQ43+1tq7utPhRBcGF6uvo/2Ofep078TxX5wp4w5tfma8QamH2Ol7kDxnuMj
TYlhRYyNXVHcTAfVGDghVsY3PBjx8xkDoxNiddkYUPmdM+Ul3EDQerJYElkbks0q
8lCUhCk7RyG7UfD/HdmxSdhpXC937cqvHWIfR2lvKsGV5TOaYGxpvZUo57qp1Ls7
iQTJ5tqZAKelEiUoC+lgsPxzxh4oMMD65Iv7yPBnRrQxnQ4E2RfocUfwJZ4sTIxg
MYm+I4VXoIIOEurvyx3xj/1iBEOFrW2YmLCbFxSOXJaAJn7yrhcCNeeBTII1lwrL
zKPluU7EcjI2T7PIqVk8nUjTrK1kEYgyC+MR1RVbsFdlyjlRyVzhdCYQ0kVoAuM7
qMKGkvj/SRyLxkoWpK84/xn+Skcof4yPpz9DxGtdET2SDZQ6Qajmve6P4wNehkF+
U6R8lDkxEqHqgSO8xVkIVOwfF1MADByPCmcNfepep5kQY5wTuOM+3b15L1saPu54
um5CXS+Fifd4WF65MJ8E//yF1LiljC1tZVdHHD580B9XbvO1oUagnMp7lBNLBFXB
FtnM3eLt06I=
=0Zb8
-----END PGP SIGNATURE-----

--==_Exmh_1349978211_1985P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
