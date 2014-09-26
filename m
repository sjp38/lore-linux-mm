Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C028082BDC
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 22:41:02 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2393309pab.4
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 19:41:02 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id y9si6574948pas.196.2014.09.25.19.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 19:41:01 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 26 Sep 2014 10:40:54 +0800
Subject: RE: [PATCH resend] arm:extend the reserved memory for initrd to be
 page aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49163B@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net>
 <20140919095959.GA2295@e104818-lin.cambridge.arm.com>
 <20140925143142.GF5182@n2100.arm.linux.org.uk>
 <20140925154403.GL10390@e104818-lin.cambridge.arm.com>
In-Reply-To: <20140925154403.GL10390@e104818-lin.cambridge.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Catalin Marinas' <catalin.marinas@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, =?iso-8859-1?Q?=27Uwe_Kleine-K=F6nig=27?= <u.kleine-koenig@pengutronix.de>, DL-WW-ContributionOfficers-Linux <DL-WW-ContributionOfficers-Linux@sonymobile.com>

> They were so close ;)
>=20
> I can see three patches but none of them exactly right:
>=20
> 8157/1 - wrong diff format
> 8159/1 - correct format, does not have my ack (you can take this one if
> 	 you want)
> 8162/1 - got my ack this time but with the wrong diff format again
>=20
> Maybe a pull request is a better idea.
>=20
I am really confused,=20
I read this web:
http://www.arm.linux.org.uk/developer/patches/info.php
it said use diff -urN to generate patch like this:

diff -Nru linux.orig/lib/string.c linux/lib/string.c

but I see other developers use git format-patch to generate patch and
submit to the patch system.
Git format-patch format can also be accepted by the patch system correctly =
?
If yes, I think this web should update,
Use git format-patch to generate patch is more convenient than use diff -ur=
N=20

Thanks



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
