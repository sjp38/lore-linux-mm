Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC6AC6B02F3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:11:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so4946455pfg.15
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:11:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h26si4094461pfa.268.2017.08.10.05.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 05:11:43 -0700 (PDT)
Date: Thu, 10 Aug 2017 05:11:39 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 21/49] blk-merge: compute bio->bi_seg_front_size
 efficiently
Message-ID: <20170810121139.GD14607@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-22-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-22-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 08, 2017 at 04:45:20PM +0800, Ming Lei wrote:
> It is enough to check and compute bio->bi_seg_front_size just
> after the 1st segment is found, but current code checks that
> for each bvec, which is inefficient.
> 
> This patch follows the way in  __blk_recalc_rq_segments()
> for computing bio->bi_seg_front_size, and it is more efficient
> and code becomes more readable too.

As far as I can tell this doesn't depend on anything else in the
series and could be sent standalone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
