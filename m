Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E35426B026C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 06:33:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so9796819pld.23
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 03:33:07 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id r3-v6si14103012plb.336.2018.07.09.03.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 03:33:06 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20180709103301euoutp028a6c909cd77964a7dc80463ebed81d2f~-rMnioL_f1086410864euoutp02H
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 10:33:01 +0000 (GMT)
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Mon, 9 Jul 2018 12:32:58 +0200
MIME-Version: 1.0
In-Reply-To: <20180702133016.GA16909@infradead.org>
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <20180709103259eucas1p1fc03f1da5e8964f903d09c5573923c10~-rMmDLdF-0476504765eucas1p12@eucas1p1.samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
	<20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
	<20180613122359.GA8695@bombadil.infradead.org>
	<20180613124001eucas1p2422f7916367ce19fecd40d6131990383~3uKFrT3ML1977219772eucas1p2G@eucas1p2.samsung.com>
	<20180613125546.GB32016@infradead.org>
	<20180613133913.GD20315@dhcp22.suse.cz>
	<20180702132335eucas1p1323fbf51cd5e82a59939d72097acee04~9kAizDyji0466904669eucas1p1w@eucas1p1.samsung.com>
	<20180702133016.GA16909@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Hi Christoph,

On 2018-07-02 15:30, Christoph Hellwig wrote:
> On Mon, Jul 02, 2018 at 03:23:34PM +0200, Marek Szyprowski wrote:
>> What about clearing the allocated buffer? Should it be another bool
>> parameter,
>> done unconditionally or moved to the callers?
> Please keep it in the callers.  I plan to push it up even higher
> from the current callers short to midterm.

Okay, I will post a patch with this approach then.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
