Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FED16B7491
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 08:37:20 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so10013386edc.9
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 05:37:20 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l16-v6si998094ejs.186.2018.12.05.05.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 05:37:19 -0800 (PST)
Subject: Re: [PATCH v4 1/3] mm: slab/slub: Add check_slab_flags function to
 check for valid flags
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-2-drinkcat@chromium.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6dc0181c-406d-bd13-f36b-98496f488979@suse.cz>
Date: Wed, 5 Dec 2018 14:34:20 +0100
MIME-Version: 1.0
In-Reply-To: <20181205054828.183476-2-drinkcat@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>, Will Deacon <will.deacon@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On 12/5/18 6:48 AM, Nicolas Boichat wrote:
> Remove duplicated code between slab and slub, and will make it
> easier to make the test more complicated in the next commits.
> 
> Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")

Well, not really. Patch 3 does that and yeah this will be a prerequisity
for a clean stable backport, but we don't tag all prerequisities like
this, I think?

> Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
