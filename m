Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 39BC76B008C
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 09:19:44 -0400 (EDT)
Received: from mail50-am1 (localhost [127.0.0.1])	by mail50-am1-R.bigfish.com
 (Postfix) with ESMTP id 1B8A22200C8	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon, 25 Mar 2013 13:18:24 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V2 1/3]  mm: Export split_page()
Date: Mon, 25 Mar 2013 13:18:15 +0000
Message-ID: <d81345b0dd4b4f509ef7206f58876afc@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1363639873-1576-1-git-send-email-kys@microsoft.com>
 <1363639898-1615-1-git-send-email-kys@microsoft.com>
 <20130319141317.GI7869@dhcp22.suse.cz>
 <3c47db9f28b944f985e8050d41334193@SN2PR03MB061.namprd03.prod.outlook.com>
In-Reply-To: <3c47db9f28b944f985e8050d41334193@SN2PR03MB061.namprd03.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>, Michal Hocko <mhocko@suse.cz>
Cc: "olaf@aepfle.de" <olaf@aepfle.de>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "yinghan@google.com" <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>



> -----Original Message-----
> From: devel [mailto:devel-bounces@linuxdriverproject.org] On Behalf Of KY
> Srinivasan
> Sent: Tuesday, March 19, 2013 5:40 PM
> To: Michal Hocko
> Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; linux-kernel@vger.kernel.=
org;
> linux-mm@kvack.org; andi@firstfloor.org; yinghan@google.com;
> hannes@cmpxchg.org; apw@canonical.com; devel@linuxdriverproject.org;
> akpm@linux-foundation.org; kamezawa.hiroyuki@gmail.com
> Subject: RE: [PATCH V2 1/3] mm: Export split_page()
>=20
>=20
>=20
> > -----Original Message-----
> > From: Michal Hocko [mailto:mhocko@suse.cz]
> > Sent: Tuesday, March 19, 2013 10:13 AM
> > To: KY Srinivasan
> > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> > andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> > kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com
> > Subject: Re: [PATCH V2 1/3] mm: Export split_page()
> >
> > On Mon 18-03-13 13:51:36, K. Y. Srinivasan wrote:
> > > This symbol would be used in the Hyper-V balloon driver to support 2M
> > > allocations.
> > >
> > > In this version of the patch, based on feedback from Michal Hocko
> > > <mhocko@suse.cz>, I have updated the patch description.
> >
> > I guess this part is not necessary ;)
> >
> > >
> > > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> >
> > Anyway
> > Acked-by: Michal Hocko <mhocko@suse.cz>
>=20
> Greg,
>=20
> Would you be taking this patch through your tree?
>=20
> Regards,

Andrew,

Could you take this patch through your tree.

Regards,

K. Y
>=20
> K. Y
> >
> > > ---
> > >  mm/page_alloc.c |    1 +
> > >  1 files changed, 1 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 6cacfee..7e0ead6 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1404,6 +1404,7 @@ void split_page(struct page *page, unsigned int
> order)
> > >  	for (i =3D 1; i < (1 << order); i++)
> > >  		set_page_refcounted(page + i);
> > >  }
> > > +EXPORT_SYMBOL_GPL(split_page);
> > >
> > >  static int __isolate_free_page(struct page *page, unsigned int order=
)
> > >  {
> > > --
> > > 1.7.4.1
> > >
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
> >
> > --
> > Michal Hocko
> > SUSE Labs
> >
>=20
>=20
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/devel
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
