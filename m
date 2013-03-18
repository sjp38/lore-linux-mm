Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2D1256B0037
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 11:11:06 -0400 (EDT)
Received: from mail211-va3 (localhost [127.0.0.1])	by
 mail211-va3-R.bigfish.com (Postfix) with ESMTP id CE9DC5201B1	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon, 18 Mar 2013 15:08:49 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 2/2] Drivers: hv: balloon: Support 2M page allocations
 for ballooning
Date: Mon, 18 Mar 2013 15:08:36 +0000
Message-ID: <98cd176931934b59a0fcb1ec3448d86c@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1363470088-24565-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-2-git-send-email-kys@microsoft.com>
 <20130318105257.GG10192@dhcp22.suse.cz>
 <1701384b10204014b53acecb006521b0@SN2PR03MB061.namprd03.prod.outlook.com>
 <20130318141302.GO10192@dhcp22.suse.cz>
In-Reply-To: <20130318141302.GO10192@dhcp22.suse.cz>
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
> Sent: Monday, March 18, 2013 10:13 AM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com
> Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Support 2M page allocation=
s for
> ballooning
>=20
> On Mon 18-03-13 13:44:05, KY Srinivasan wrote:
> >
> >
> > > -----Original Message-----
> > > From: Michal Hocko [mailto:mhocko@suse.cz]
> > > Sent: Monday, March 18, 2013 6:53 AM
> > > To: KY Srinivasan
> > > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > > devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> > > andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> > > kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org;
> yinghan@google.com
> > > Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Support 2M page alloca=
tions for
> > > ballooning
> > >
> > > On Sat 16-03-13 14:42:05, K. Y. Srinivasan wrote:
> > > > While ballooning memory out of the guest, attempt 2M allocations fi=
rst.
> > > > If 2M allocations fail, then go for 4K allocations. In cases where =
we
> > > > have performed 2M allocations, split this 2M page so that we can fr=
ee this
> > > > page at 4K granularity (when the host returns the memory).
> > >
> > > Maybe I am missing something but what is the advantage of 2M allocati=
on
> > > when you split it up immediately so you are not using it as a huge pa=
ge?
> >
> > The Hyper-V ballooning protocol specifies the pages being ballooned as
> > page ranges - start_pfn: number_of_pfns. So, when the guest balloon
> > is inflating and I am able to allocate 2M pages, I will be able to
> > represent 512 contiguous pages in one 64 bit entry and this makes the
> > ballooning operation that much more efficient. The reason I split the
> > page is that the host does not guarantee that when it returns the
> > memory to the guest, it will return in any particular granularity and
> > so I have to be able to free this memory in 4K granularity. This is
> > the corner case that I will have to handle.
>=20
> Thanks for the clarification. I think this information would be valuable
> in the changelog.

Thanks Michal. I will resend the patches with the changes you have suggeste=
d. What is your
recommendation with regards which tree the mm patch needs to go through; th=
e Hyper-V balloon
driver patch will go through Greg's tree.

Regards,

K. Y=20
> --
> Michal Hocko
> SUSE Labs
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
