Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8876B02CE
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 10:45:35 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u15so29579396oie.6
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 07:45:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id eg4si2521942pac.238.2016.11.03.07.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 07:45:34 -0700 (PDT)
Date: Thu, 3 Nov 2016 07:45:32 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [mm PATCH v2 01/26] swiotlb: Drop unused functions
 swiotlb_map_sg and swiotlb_unmap_sg
Message-ID: <20161103144532.GA14340@infradead.org>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
 <20161103141446.GA29720@infradead.org>
 <20161103142952.GJ28691@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103142952.GJ28691@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 03, 2016 at 10:29:52AM -0400, Konrad Rzeszutek Wilk wrote:
> Somehow I thought you wanted to put them through your tree (which
> is why I acked them).
> 
> I can take them and also the first couple of Alexander through
> my tree. Or if it makes it simpler - they can go through the -mm tree?

I don't have a tree for it, so I kinda expected you to pick it up.
But I'm also fine with you just Acking the version from Alex and having
him funnel it through whatever tree he wants to get his patches in
through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
