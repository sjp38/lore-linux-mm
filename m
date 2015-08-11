Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8305B6B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 06:47:37 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so82461823pdr.2
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 03:47:37 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id qc7si2806653pdb.74.2015.08.11.03.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Aug 2015 03:47:36 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSW002Y7ZAWA360@mailout1.samsung.com> for linux-mm@kvack.org;
 Tue, 11 Aug 2015 19:47:20 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1438956233-28690-1-git-send-email-pintu.k@samsung.com>
 <55C4BE1A.8050408@suse.cz>
In-reply-to: <55C4BE1A.8050408@suse.cz>
Subject: RE: [PATCH 1/1] mm: compaction: include compact_nodes in compaction.h
Date: Tue, 11 Aug 2015 16:15:54 +0530
Message-id: <040301d0d423$0f1b36d0$2d51a470$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, mhocko@suse.cz, riel@redhat.com, emunson@akamai.com, mgorman@suse.de, zhangyanfei@cn.fujitsu.com, rientjes@google.com
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

Hi,

> -----Original Message-----
> From: Vlastimil Babka [mailto:vbabka@suse.cz]
> Sent: Friday, August 07, 2015 7:48 PM
> To: Pintu Kumar; akpm@linux-foundation.org; =
linux-kernel@vger.kernel.org;
> linux-mm@kvack.org; iamjoonsoo.kim@lge.com; mhocko@suse.cz;
> riel@redhat.com; emunson@akamai.com; mgorman@suse.de;
> zhangyanfei@cn.fujitsu.com; rientjes@google.com
> Cc: cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.k@outlook.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com
> Subject: Re: [PATCH 1/1] mm: compaction: include compact_nodes in
> compaction.h
>=20
> On 08/07/2015 04:03 PM, Pintu Kumar wrote:
> > This patch declares compact_nodes prototype in compaction.h header
> > file.
> > This will allow us to call compaction from other places.
> > For example, during system suspend, suppose we want to check the
> > fragmentation state of the system. Then based on certain threshold, =
we
> > can invoke compaction, when system is idle.
> > There could be other use cases.
>=20
> Isn't it more common to introduce such visibility changes only as part =
of series
> that actually benefit from it?
>=20
Other series are not ready right now and not defined yet. It may take =
longer time.
I thought, it is left to the user, if somebody wants to invoke =
compaction from other sub-system.

> Otherwise next month somebody might notice that it's unused outside
> compaction.c and send a cleanup patch to make it static again...
>=20
> > Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> > ---
> >   include/linux/compaction.h |    2 +-
> >   mm/compaction.c            |    2 +-
> >   2 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index aa8f61c..800ff50 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -50,7 +50,7 @@ extern bool compaction_deferred(struct zone *zone, =
int
> order);
> >   extern void compaction_defer_reset(struct zone *zone, int order,
> >   				bool alloc_success);
> >   extern bool compaction_restarting(struct zone *zone, int order);
> > -
> > +extern void compact_nodes(void);
> >   #else
> >   static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
> >   			unsigned int order, int alloc_flags, diff --git
> a/mm/compaction.c
> > b/mm/compaction.c index 16e1b57..b793922 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1657,7 +1657,7 @@ static void compact_node(int nid)
> >   }
> >
> >   /* Compact all nodes in the system */ -static void
> > compact_nodes(void)
> > +void compact_nodes(void)
> >   {
> >   	int nid;
> >
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
