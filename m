Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B80736B005A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 07:55:27 -0500 (EST)
Received: from eusync1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDW0063Y3WTAF90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Nov 2012 12:55:41 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync1.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MDW00A8U3WBZ830@eusync1.samsung.com> for linux-mm@kvack.org;
 Thu, 22 Nov 2012 12:55:25 +0000 (GMT)
Message-id: <50AE20BB.7030107@samsung.com>
Date: Thu, 22 Nov 2012 13:55:23 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com>
 <20121120113325.dde266ed.akpm@linux-foundation.org>
 <50AC8C14.5050204@samsung.com>
 <20121121003643.97febbdb.akpm@linux-foundation.org>
 <50AC9CC7.8010103@samsung.com>
 <20121121111711.fe915265.akpm@linux-foundation.org>
In-reply-to: <20121121111711.fe915265.akpm@linux-foundation.org>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Soren Moch <smoch@web.de>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>


On 11/21/2012 8:17 PM, Andrew Morton wrote:
> On Wed, 21 Nov 2012 10:20:07 +0100
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> > On 11/21/2012 9:36 AM, Andrew Morton wrote:
> > > On Wed, 21 Nov 2012 09:08:52 +0100 Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> > > > On 11/20/2012 8:33 PM, Andrew Morton wrote:
> > > > > On Tue, 20 Nov 2012 15:31:45 +0100
> > > > > Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> > > > >
> > > > > > dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag,
> > > > > > regardless the flags provided by the caller. This causes excessive
> > > > > > pruning of emergency memory pools without any good reason. Additionaly,
> > > > > > on ARM architecture any driver which is using dmapools will sooner or
> > > > > > later  trigger the following error:
> > > > > > "ERROR: 256 KiB atomic DMA coherent pool is too small!
> > > > > > Please increase it with coherent_pool= kernel parameter!".
> > > > > > Increasing the coherent pool size usually doesn't help much and only
> > > > > > delays such error, because all GFP_ATOMIC DMA allocations are always
> > > > > > served from the special, very limited memory pool.
> > > > > >
> > > > >
> > > > > Is this problem serious enough to justify merging the patch into 3.7?
> > > > > And into -stable kernels?
> > > >
> > > > I wonder if it is a good idea to merge such change at the end of current
> > > > -rc period.
> > >
> > > I'm not sure what you mean by this.
> > >
> > > But what we do sometimes if we think a patch needs a bit more
> > > real-world testing before backporting is to merge it into -rc1 in the
> > > normal merge window, and tag it for -stable backporting.  That way it
> > > gets a few weeks(?) testing in mainline before getting backported.
> >
> > I just wondered that if it gets merged to v3.7-rc7 there won't be much time
> > for real-world testing before final v3.7 release. This patch is in
> > linux-next for over a week and I'm not aware of any issues, but -rc releases
> > gets much more attention and testing than linux-next tree.
> >
> > If You think it's fine to put such change to v3.7-rc7 I will send a pull
> > request and tag it for stable asap.
>
> What I'm suggesting is that it be merged for 3.8-rc1 with a -stable
> tag, then it will be backported into 3.7.x later on.

OK, I will push it to v3.8-rc1 then and tag for stable.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
