Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C41436B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:06:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s70so169676364pfs.5
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:06:41 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id u2si13565461plj.486.2017.07.17.09.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 09:06:40 -0700 (PDT)
Subject: Re: semantics of dma_map_single()
References: <dc128260-6641-828a-3bb6-c2f0b4f09f78@synopsys.com>
 <20170717064220.GA15807@lst.de>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <23203d16-da54-99c7-0eba-c082eba120d7@synopsys.com>
Date: Mon, 17 Jul 2017 09:06:29 -0700
MIME-Version: 1.0
In-Reply-To: <20170717064220.GA15807@lst.de>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, bart.vanassche@sandisk.com, Alexander Duyck <alexander.h.duyck@intel.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>

Hi Christoph,

On 07/16/2017 11:42 PM, Christoph Hellwig wrote:
> I would expect that it would support any contiguous range in
> the kernel mapping (e.g. no vmalloc and friends).  But it's not
> documented anywhere, and if no in kernel users makes use of that
> fact at the moment it might be better to document a page size
> limitation and add asserts to enforce it.

My first thought was indeed to add a BUG_ON for @size > PAGE_SIZE (also accounting 
for offset etc), but I have a feeling this will cause too many breakages. So 
perhaps it would be better to add the fact to Documentation that it can handle any 
physically contiguous range.

-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
