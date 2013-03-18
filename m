Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 70ED46B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 09:29:20 -0400 (EDT)
Received: from mail70-db8 (localhost [127.0.0.1])	by mail70-db8-R.bigfish.com
 (Postfix) with ESMTP id C307FB000D6	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon, 18 Mar 2013 13:28:49 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/2] mm: Export split_page()
Date: Mon, 18 Mar 2013 13:28:42 +0000
Message-ID: <991ac805538f4d5f9698200d592bddb6@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1363470088-24565-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-1-git-send-email-kys@microsoft.com>
 <20130318110334.GI10192@dhcp22.suse.cz>
In-Reply-To: <20130318110334.GI10192@dhcp22.suse.cz>
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
> Sent: Monday, March 18, 2013 7:04 AM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com
> Subject: Re: [PATCH 1/2] mm: Export split_page()
>=20
> On Sat 16-03-13 14:42:04, K. Y. Srinivasan wrote:
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
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
>=20
> I do not have any objections to exporting the symbol (at least we
> prevent drivers code from inventing their own split_page) but the
> Hyper-V specific description should go into Hyper-V patch IMO.
>=20
> So for the export with a short note that the symbol will be used by
> Hyper-V

Will do.

K. Y
> Acked-by: Michal Hocko <mhocko@suse.cz>
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
