Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 8B72E6B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 21:14:39 -0500 (EST)
Received: from mail47-db9 (localhost [127.0.0.1])	by mail47-db9-R.bigfish.com
 (Postfix) with ESMTP id 331591800ED	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon,  4 Mar 2013 02:14:08 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] mm: Export split_page().
Date: Mon, 4 Mar 2013 02:14:02 +0000
Message-ID: <3a362e994ab64efda79ae3c80342db95@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1362364075-14564-1-git-send-email-kys@microsoft.com>
 <20130304020747.GA8265@kroah.com>
In-Reply-To: <20130304020747.GA8265@kroah.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Sunday, March 03, 2013 9:08 PM
> To: KY Srinivasan
> Cc: linux-kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepf=
le.de;
> apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linux-
> mm@kvack.org
> Subject: Re: [PATCH 1/1] mm: Export split_page().
>=20
> On Sun, Mar 03, 2013 at 06:27:55PM -0800, K. Y. Srinivasan wrote:
> > The split_page() function will be very useful for balloon drivers. On H=
yper-V,
> > it will be very efficient to use 2M allocations in the guest as this (a=
) makes
> > the ballooning protocol with the host that much more efficient and (b) =
moving
> > memory in 2M chunks minimizes fragmentation in the host. Export the
> split_page()
> > function to let the guest allocations be in 2M chunks while the host is=
 free to
> > return this memory at arbitrary granularity.
> >
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  mm/page_alloc.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6cacfee..7e0ead6 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1404,6 +1404,7 @@ void split_page(struct page *page, unsigned int o=
rder)
> >  	for (i =3D 1; i < (1 << order); i++)
> >  		set_page_refcounted(page + i);
> >  }
> > +EXPORT_SYMBOL_GPL(split_page);
>=20
> When you export a symbol, you also need to post the code that is going
> to use that symbol, otherwise people don't really know how to judge this
> request.
>=20
> Can you just make this a part of your balloon driver update patch series
> instead?

Fair enough; I was hoping to see how inclined the mm folks were with regard=
s to
exporting this symbol before I went ahead and modified the balloon driver c=
ode to
leverage this. Looking at the Windows guests on Hyper-V, I am convinced 2M =
balloon
allocations in the Linux (Hyper-V) balloon driver will make significant dif=
ference. As you
suggest, I will post this patch as part of the balloon driver changes that =
use this exported
symbol. I am still hoping to get some feedback from the mm guys on this.

Regards,

K. Y


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
