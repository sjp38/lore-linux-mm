Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EEEF5280031
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:59:44 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so6802229pdb.21
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:59:44 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id bf4si8619292pdb.162.2014.10.31.00.59.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 00:59:44 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 31 Oct 2014 15:59:37 +0800
Subject: RE: [RFC] arm:remove clear_thread_flag(TIF_UPROBE)
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1827E@CNBJMBX05.corpusers.net>
References: <1414392371.8884.2.camel@perches.com>
	 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
	 <20141030120127.GC32589@arm.com>
	 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
	 <20141030135749.GE32589@arm.com>
	 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D1827B@CNBJMBX05.corpusers.net>
	 <1414741535.8928.2.camel@perches.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1827C@CNBJMBX05.corpusers.net>
 <1414742289.8928.5.camel@perches.com>
In-Reply-To: <1414742289.8928.5.camel@perches.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joe Perches' <joe@perches.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> From: Joe Perches [mailto:joe@perches.com]
> > > > @@ -591,10 +591,9 @@ do_work_pending(struct pt_regs *regs, unsigned
> int
> > > thread_flags, int syscall)
> > > >  					return restart;
> > > >  				}
> > > >  				syscall =3D 0;
> > > > -			} else if (thread_flags & _TIF_UPROBE) {
> > > > -				clear_thread_flag(TIF_UPROBE);
> > > > +			} else if (thread_flags & _TIF_UPROBE)
> > > >  				uprobe_notify_resume(regs);
> > > > -			} else {
> > > > +			else {
> > > >  				clear_thread_flag(TIF_NOTIFY_RESUME);
> > > >  				tracehook_notify_resume(regs);
> > > >  			}
> > >
> > > Please keep the braces.
> >
> > mm..  could I know the reason ?  :)
>=20
> Try read Documentation/CodingStyle
>=20
> 		Chapter 3: Placing Braces and Spaces
>=20
> use braces in both branches:
>=20
> if (condition) {
> 	do_this();
> 	do_that();
> } else {
> 	otherwise();
> }
>=20

Got it,  I will resend one .
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
