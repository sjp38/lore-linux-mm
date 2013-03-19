Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id F12B86B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 17:41:37 -0400 (EDT)
Received: from mail127-tx2 (localhost [127.0.0.1])	by
 mail127-tx2-R.bigfish.com (Postfix) with ESMTP id 766231801EE	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 19 Mar 2013 21:39:54 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V2 1/3]  mm: Export split_page()
Date: Tue, 19 Mar 2013 21:39:46 +0000
Message-ID: <3c47db9f28b944f985e8050d41334193@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1363639873-1576-1-git-send-email-kys@microsoft.com>
 <1363639898-1615-1-git-send-email-kys@microsoft.com>
 <20130319141317.GI7869@dhcp22.suse.cz>
In-Reply-To: <20130319141317.GI7869@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Tuesday, March 19, 2013 10:13 AM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com
> Subject: Re: [PATCH V2 1/3] mm: Export split_page()
>=20
> On Mon 18-03-13 13:51:36, K. Y. Srinivasan wrote:
> > This symbol would be used in the Hyper-V balloon driver to support 2M
> > allocations.
> >
> > In this version of the patch, based on feedback from Michal Hocko
> > <mhocko@suse.cz>, I have updated the patch description.
>=20
> I guess this part is not necessary ;)
>=20
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
>=20
> Anyway
> Acked-by: Michal Hocko <mhocko@suse.cz>

Greg,

Would you be taking this patch through your tree?

Regards,

K. Y
>=20
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
> >
> >  static int __isolate_free_page(struct page *page, unsigned int order)
> >  {
> > --
> > 1.7.4.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
>=20
> --
> Michal Hocko
> SUSE Labs
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
