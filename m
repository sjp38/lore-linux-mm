Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5A7D6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:00:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 24so4981983pfk.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:00:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s72si4031507pfa.411.2017.08.10.05.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 05:00:35 -0700 (PDT)
Date: Thu, 10 Aug 2017 05:00:29 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 18/49] block: introduce multipage/single page bvec
 helpers
Message-ID: <20170810120029.GA14607@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-19-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-19-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Please skip adding the _sp names for the single page ones - those
are the only used to implement the non postfixed ones anyway.

The _mp ones should have bio_iter_segment_* names instead.

And while you're at it - I think this code would massively benefit
from turning it into inline functions in a prep step before doing these
changes, including passing the iter by reference for all these functions
instead of the odd by value calling convention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
