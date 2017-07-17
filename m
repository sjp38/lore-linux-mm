Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 304B96B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:42:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t3so18302436wme.9
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 23:42:22 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m20si9006613wmi.39.2017.07.16.23.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 23:42:21 -0700 (PDT)
Date: Mon, 17 Jul 2017 08:42:20 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: semantics of dma_map_single()
Message-ID: <20170717064220.GA15807@lst.de>
References: <dc128260-6641-828a-3bb6-c2f0b4f09f78@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dc128260-6641-828a-3bb6-c2f0b4f09f78@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>, bart.vanassche@sandisk.com, Alexander Duyck <alexander.h.duyck@intel.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>

I would expect that it would support any contiguous range in
the kernel mapping (e.g. no vmalloc and friends).  But it's not
documented anywhere, and if no in kernel users makes use of that
fact at the moment it might be better to document a page size
limitation and add asserts to enforce it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
