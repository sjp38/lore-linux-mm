Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6496B0035
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 21:50:31 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so1238704pdb.39
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 18:50:30 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id bn6si16205869pdb.215.2014.09.27.18.50.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 18:50:29 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Sun, 28 Sep 2014 09:50:21 +0800
Subject: RE: [PATCH resend] arm:extend the reserved memory for initrd to be
 page aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49163E@CNBJMBX05.corpusers.net>
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

> -----Original Message-----
> On Thu, Sep 25, 2014 at 03:31:42PM +0100, Russell King - ARM Linux wrote:
> > On Fri, Sep 19, 2014 at 11:00:02AM +0100, Catalin Marinas wrote:
> > > On Fri, Sep 19, 2014 at 08:09:47AM +0100, Wang, Yalin wrote:
> > > > this patch extend the start and end address of initrd to be page
> > > > aligned, so that we can free all memory including the un-page
> > > > aligned head or tail page of initrd, if the start or end address
> > > > of initrd are not page aligned, the page can't be freed by
> free_initrd_mem() function.
> > > >
> > > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > >
> > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > >
> > > (as I said, if Russell doesn't have any objections please send the
> > > patch to his patch system)
> >
> > I now have an objection.  The patches in the emails were properly
> formatted.
>=20
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
I have resend the 2 patches:
http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=3D8167/1
http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=3D8168/1
=20
please have a look.

Thanks



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
