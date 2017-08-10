Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39DD06B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:28:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so3993076pfj.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:28:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g14si4355673plj.817.2017.08.10.04.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:28:09 -0700 (PDT)
Date: Thu, 10 Aug 2017 04:28:05 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 09/49] block: comment on bio_iov_iter_get_pages()
Message-ID: <20170810112805.GE20308@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-10-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-10-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

> + * The hacking way of using bvec table as page pointer array is safe
> + * even after multipage bvec is introduced because that space can be
> + * thought as unused by bio_add_page().

I'm not sure what value this comment adds.

Note that once we have multi-page biovecs this could should change
to take advantage of multipage biovecs, so adding a comment before
that doesn't seem too helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
