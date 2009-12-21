Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F26F46B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 04:21:25 -0500 (EST)
From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Date: Mon, 21 Dec 2009 14:51:13 +0530
Subject: RE: CPU consumption is going as high as 95% on ARM Cortex A8
Message-ID: <19F8576C6E063C45BE387C64729E73940449F43EEE@dbde02.ent.ti.com>
References: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
 <20091217095641.GA399@n2100.arm.linux.org.uk>
 <19F8576C6E063C45BE387C64729E73940449F43E29@dbde02.ent.ti.com>
 <20091221090750.GA11669@n2100.arm.linux.org.uk>
In-Reply-To: <20091221090750.GA11669@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> -----Original Message-----
> From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> Sent: Monday, December 21, 2009 2:38 PM
> To: Hiremath, Vaibhav
> Cc: linux-arm-kernel@lists.infradead.org; linux-mm@kvack.org; linux-
> omap@vger.kernel.org
> Subject: Re: CPU consumption is going as high as 95% on ARM Cortex
> A8
>=20
> On Mon, Dec 21, 2009 at 11:56:23AM +0530, Hiremath, Vaibhav wrote:
> > >         vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
> > >
> > > will result in the memory being mapped as 'Strongly Ordered',
> > > resulting
> > > in there being multiple mappings with differing types.  In later
> > > kernels, we have pgprot_dmacoherent() and I'd suggest changing
> the
> > > above
> > > macro for that.
> > >
> >
> > I tried with your suggestion above but unfortunately it didn't
> work for
> > me. I am seeing the same behavior with the pgprot_dmacoherent(). I
> > pulled your patch (which got applied cleanly on 2.6.32-rc5) -
>=20
> What happens if you comment out the pgprot_dmacoherent() /
> pgprot_noncached()
> line completely?
>=20
[Hiremath, Vaibhav] If I comment the line completely then I am seeing CPU c=
onsumption similar to when I was setting PAGE_READONLY/PAGE_SHARED flag, wh=
ich is 25-32%.

Thanks,
Vaibhav

> I suspect that will "solve" the problem - but you'll then no longer
> have
> DMA coherency with userspace, so its not really a solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
