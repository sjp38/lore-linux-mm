Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF0C16B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:29:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r187so4136000pfr.8
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:29:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x2si4503801plm.636.2017.08.10.04.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:29:07 -0700 (PDT)
Date: Thu, 10 Aug 2017 04:29:00 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 10/49] dm: limit the max bio size as BIO_MAX_PAGES *
 PAGE_SIZE
Message-ID: <20170810112900.GF20308@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-11-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-11-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Snitzer <snitzer@redhat.com>

> +	ti->max_io_len = min_t(uint32_t, len,
> +			       (BIO_MAX_PAGES * PAGE_SIZE));

No need for the inner braces.  Also all of the above fits nicely
onto a single < 80 char line.

Otherwise this looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
