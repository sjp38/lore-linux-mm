Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9E7936B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 03:52:26 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M970060E77CBF00@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Aug 2012 16:52:24 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M9700BKZ76WN630@mmp2.samsung.com> for linux-mm@kvack.org;
 Thu, 23 Aug 2012 16:52:24 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
 <1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
 <CAHQjnOOF7Ca-Dz8K_zcS=gxQsJvKYaWA3tqUeK1RSd-wLYZ44w@mail.gmail.com>
 <20120822.163648.3800987367886904.hdoyu@nvidia.com>
 <012401cd80f4$59727020$0c575060$%szyprowski@samsung.com>
 <20120823091519.804aeae4ba93bcfe011e787c@nvidia.com>
In-reply-to: <20120823091519.804aeae4ba93bcfe011e787c@nvidia.com>
Subject: RE: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool with
 GFP_ATOMIC
Date: Thu, 23 Aug 2012 09:52:07 +0200
Message-id: <014501cd8104$35a8ce40$a0fa6ac0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: pullip.cho@samsung.com, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, 'Krishna Reddy' <vdumpa@nvidia.com>, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org

Hi Hiroshi,

On Thursday, August 23, 2012 8:15 AM Hiroshi Doyu wrote:

> On Thu, 23 Aug 2012 07:58:34 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > Hello,
> >
> > On Wednesday, August 22, 2012 3:37 PM Hiroshi Doyu wrote:
> >
> > > KyongHo Cho <pullip.cho@samsung.com> wrote @ Wed, 22 Aug 2012 14:47:00 +0200:
> > >
> > > > vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic context.
> > >
> > > Right.
> > >
> > > I've been thinking that kzalloc() may be enough here, since
> > > vzalloc() was introduced to avoid allocation failure for big chunk of
> > > memory, but I think that it's unlikely that the number of page array
> > > can be so big. So I propose to drop vzalloc() here, and just simply to
> > > use kzalloc only as below(*1).
> >
> > We already had a discussion about this, so I don't think it makes much sense to
> > change it back to kzalloc. This vmalloc() call won't hurt anyone. It should not
> > be considered a problem for atomic allocations, because no sane driver will try
> > to allocate buffers larger than a dozen KiB with GFP_ATOMIC flag. I would call
> > such try a serious bug, which we should not care here.
> 
> Ok, I've already sent v2 just now, where, instead of changing it back,
> just with GFP_ATOMIC, kzalloc() would be selected, just in case. I guess
> that this would be ok(a bit safer?)

I've posted some comments to v2. If you agree with my suggestion, no changes around
those vmalloc() calls will be needed.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
