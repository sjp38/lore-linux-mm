Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 715E16B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:24:59 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id fq2so83945732obb.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 00:24:59 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n67si3323484ion.248.2016.06.29.00.24.57
        for <linux-mm@kvack.org>;
        Wed, 29 Jun 2016 00:24:58 -0700 (PDT)
Date: Wed, 29 Jun 2016 16:25:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm, vmscan: set shrinker to the left page count
Message-ID: <20160629072524.GA18523@bbox>
References: <1467025335-6748-1-git-send-email-puck.chen@hisilicon.com>
 <20160627165723.GW21652@esperanza>
 <57725364.60307@hisilicon.com>
MIME-Version: 1.0
In-Reply-To: <57725364.60307@hisilicon.com>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, labbott@redhat.com, suzhuangluan@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com, dan.zhao@hisilicon.com, saberlily.xia@hisilicon.com, xuyiping@hisilicon.com

On Tue, Jun 28, 2016 at 06:37:24PM +0800, Chen Feng wrote:
> Thanks for you reply.
>=20
> On 2016/6/28 0:57, Vladimir Davydov wrote:
> > On Mon, Jun 27, 2016 at 07:02:15PM +0800, Chen Feng wrote:
> >> In my platform, there can be cache a lot of memory in
> >> ion page pool. When shrink memory the nr=5Fto=5Fscan to ion
> >> is always to little.
> >> to=5Fscan: 395  ion=5Fpool=5Fcached: 27305
> >=20
> > That's OK. We want to shrink slabs gradually, not all at once.
> >=20
>=20
> OK=EF=BC=8C But my question there are a lot of memory waiting for free.
> But the to=5Fscan is too little.
>=20
> So, the lowmemorykill may kill the wrong process.

So, the problem is LMK is too agressive. If it's really problem,
you could fix LMK to consider reclaimable slab as well as file
pages.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
