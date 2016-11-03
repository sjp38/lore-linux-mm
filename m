Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36D5D6B02D0
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 11:02:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x70so12686788pfk.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 08:02:58 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a76si10083412pfc.86.2016.11.03.08.02.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 08:02:57 -0700 (PDT)
From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [mm PATCH v2 01/26] swiotlb: Drop unused functions
 swiotlb_map_sg and swiotlb_unmap_sg
Date: Thu, 3 Nov 2016 15:02:21 +0000
Message-ID: <B1C1DF2ACD01FD4881736AA51731BAB2A28C7A@ORSMSX107.amr.corp.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
 <20161103141446.GA29720@infradead.org>
 <20161103142952.GJ28691@localhost.localdomain>
 <20161103144532.GA14340@infradead.org>
In-Reply-To: <20161103144532.GA14340@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Thursday, November 3, 2016 7:46 AM
> To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Christoph Hellwig <hch@infradead.org>; Duyck, Alexander H
> <alexander.h.duyck@intel.com>; linux-mm@kvack.org; akpm@linux-
> foundation.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [mm PATCH v2 01/26] swiotlb: Drop unused functions
> swiotlb_map_sg and swiotlb_unmap_sg
>=20
> On Thu, Nov 03, 2016 at 10:29:52AM -0400, Konrad Rzeszutek Wilk wrote:
> > Somehow I thought you wanted to put them through your tree (which is
> > why I acked them).
> >
> > I can take them and also the first couple of Alexander through my
> > tree. Or if it makes it simpler - they can go through the -mm tree?
>=20
> I don't have a tree for it, so I kinda expected you to pick it up.
> But I'm also fine with you just Acking the version from Alex and having h=
im
> funnel it through whatever tree he wants to get his patches in through.

For the first 3 patches in my series I am fine with them being pulled into =
the swiotlb tree.  So if you want to pull Christoph's two patches, and then=
 drop my duplicate patch and instead pull the next 2 I could submit a v3 of=
 my series without the swiotlb patches in it.

At this point I have redone my series so that I technically don't have anyt=
hing with a hard dependency on the DMA_ATTR_SKIP_CPU_SYNC actually doing an=
ything yet.  My plan is to get this all into Linus's tree first via whateve=
r tree I can get these patches pulled into and once I have all that I will =
start updating drivers in net-next.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
