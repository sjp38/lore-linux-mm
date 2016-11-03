Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D20916B02CA
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 10:14:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g193so48259729qke.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 07:14:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id yw3si8185809pac.164.2016.11.03.07.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 07:14:47 -0700 (PDT)
Date: Thu, 3 Nov 2016 07:14:46 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [mm PATCH v2 01/26] swiotlb: Drop unused functions
 swiotlb_map_sg and swiotlb_unmap_sg
Message-ID: <20161103141446.GA29720@infradead.org>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Nov 02, 2016 at 07:12:31AM -0400, Alexander Duyck wrote:
> There are no users for swiotlb_map_sg or swiotlb_unmap_sg so we might as
> well just drop them.

FYI, I sent the same patch already on Sep, 11 and Konrad already ACKed
it:

https://lkml.org/lkml/2016/9/11/112
https://lkml.org/lkml/2016/9/16/474

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
