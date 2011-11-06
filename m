Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8826B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 16:35:33 -0500 (EST)
Received: by faaf16 with SMTP id f16so6214632faa.14
        for <linux-mm@kvack.org>; Sun, 06 Nov 2011 13:35:29 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: CMA v16 and DMA-mapping v13 patch series
References: <ADF13DA15EB3FE4FBA487CCC7BEFDF3622549EBE58@bssrvexch01>
Date: Sun, 06 Nov 2011 22:35:16 +0100
In-Reply-To: <ADF13DA15EB3FE4FBA487CCC7BEFDF3622549EBE58@bssrvexch01> (Marek
	Szyprowski's message of "Thu, 20 Oct 2011 08:01:12 +0200")
Message-ID: <87lirtgciz.fsf@erwin.mina86.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, 'Subash Patel' <subashrp@gmail.com>, Joerg Roedel <joro@8bytes.org>, Shariq Hasnain <shariq.hasnain@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>

--=-=-=
Content-Transfer-Encoding: quoted-printable

Marek Szyprowski <m.szyprowski@samsung.com> writes:
> Linux v3.1-rc10 with both CMA v16 and DMA-mapping v3:
> git://git.infradead.org/users/kmpark/linux-2.6-samsung 3.1-rc10-cma-v16-d=
ma-v3

I've pushed a new version based on Mel's suggestions to=20

     git://github.com/mina86/linux-2.6.git cma-17

Unfortunately, it took me more time then I anticipated and so I had no
time to test the code in any way (other then compile it on x86_64).

=2D-=20
Best regards,                                          _     _
 .o. | Liege of Serenly Enlightened Majesty of       o' \,=3D./ `o
 ..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
 ooo +-<mina86-mina86.com>-<jid:mina86-jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk62/Z4ACgkQUyzLALfG3x79TwCghV+S7VGchGmHFCcE70bs9kwB
93kAn1QslNio6hpatD2GoUQLjzYxSyJJ
=UBof
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
