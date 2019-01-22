Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEEA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 17:51:19 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so291767qtb.9
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 14:51:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor114152754qtn.60.2019.01.22.14.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 14:51:18 -0800 (PST)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com> <20190111102155.in5rctq5krs4ewfi@8bytes.org>
In-Reply-To: <20190111102155.in5rctq5krs4ewfi@8bytes.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 23 Jan 2019 06:51:05 +0800
Message-ID: <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org, Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>, stable@vger.kernel.org, Joerg Roedel <joro@8bytes.org>

Hi Andrew,

On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
>
> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
> > Does anyone have any further comment on this series? If not, which
> > maintainer is going to pick this up? I assume Andrew Morton?
>
> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
> this should go through mm.

Gentle ping on this series, it seems like it's better if it goes
through your tree.

Series still applies cleanly on linux-next, but I'm happy to resend if
that helps.

Thanks!

> Regards,
>
>         Joerg
