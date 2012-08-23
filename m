Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 190866B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 02:17:32 -0400 (EDT)
Date: Thu, 23 Aug 2012 09:15:19 +0300
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: Re: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool
 with GFP_ATOMIC
Message-ID: <20120823091519.804aeae4ba93bcfe011e787c@nvidia.com>
In-Reply-To: <012401cd80f4$59727020$0c575060$%szyprowski@samsung.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
	<1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
	<CAHQjnOOF7Ca-Dz8K_zcS=gxQsJvKYaWA3tqUeK1RSd-wLYZ44w@mail.gmail.com>
	<20120822.163648.3800987367886904.hdoyu@nvidia.com>
	<012401cd80f4$59727020$0c575060$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

Hi,

On Thu, 23 Aug 2012 07:58:34 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> Hello,
> 
> On Wednesday, August 22, 2012 3:37 PM Hiroshi Doyu wrote:
> 
> > KyongHo Cho <pullip.cho@samsung.com> wrote @ Wed, 22 Aug 2012 14:47:00 +0200:
> > 
> > > vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic context.
> > 
> > Right.
> > 
> > I've been thinking that kzalloc() may be enough here, since
> > vzalloc() was introduced to avoid allocation failure for big chunk of
> > memory, but I think that it's unlikely that the number of page array
> > can be so big. So I propose to drop vzalloc() here, and just simply to
> > use kzalloc only as below(*1).
> 
> We already had a discussion about this, so I don't think it makes much sense to
> change it back to kzalloc. This vmalloc() call won't hurt anyone. It should not
> be considered a problem for atomic allocations, because no sane driver will try
> to allocate buffers larger than a dozen KiB with GFP_ATOMIC flag. I would call
> such try a serious bug, which we should not care here.

Ok, I've already sent v2 just now, where, instead of changing it back,
just with GFP_ATOMIC, kzalloc() would be selected, just in case. I guess
that this would be ok(a bit safer?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
