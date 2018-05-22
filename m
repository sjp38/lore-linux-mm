Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60E6B6B0282
	for <linux-mm@kvack.org>; Tue, 22 May 2018 07:52:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m15-v6so17702064qti.16
        for <linux-mm@kvack.org>; Tue, 22 May 2018 04:52:07 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.204])
        by mx.google.com with ESMTPS id z48-v6si7053820qvg.97.2018.05.22.04.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 04:52:06 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v2 10/12] mm/zsmalloc: update usage of
 address zone modifiers
Date: Tue, 22 May 2018 11:51:52 +0000
Message-ID: <HK2PR03MB16844D405C08B595CD682B6592940@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <1526916033-4877-11-git-send-email-yehs2007@gmail.com>
 <20180522112230.GA5412@bombadil.infradead.org>
In-Reply-To: <20180522112230.GA5412@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Huaisheng Ye <yehs2007@gmail.com>, Christoph Hellwig <hch@lst.de>

From: owner-linux-mm@kvack.org On Behalf Of Matthew Wilcox
>=20
> On Mon, May 21, 2018 at 11:20:31PM +0800, Huaisheng Ye wrote:
> > @@ -343,7 +343,7 @@ static void destroy_cache(struct zs_pool *pool)
> >  static unsigned long cache_alloc_handle(struct zs_pool *pool, gfp_t gf=
p)
> >  {
> >  	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
> > -			gfp & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
> > +			gfp & ~__GFP_ZONE_MOVABLE);
> >  }
>=20
> This should be & ~GFP_ZONEMASK
>=20
> Actually, we should probably have a function to clear those bits rather
> than have every driver manipulating the gfp mask like this.  Maybe
>=20
> #define gfp_normal(gfp)		((gfp) & ~GFP_ZONEMASK)

Good idea!

>=20
> 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
> -			gfp & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
> +			gfp_normal(gfp));


Sincerely,
Huaisheng Ye
