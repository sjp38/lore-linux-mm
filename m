Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4DB6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:13:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so3681008pgb.13
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:13:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f1si4009854pfg.494.2017.08.10.04.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:12:59 -0700 (PDT)
Date: Thu, 10 Aug 2017 04:12:53 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 01/49] block: drbd: comment on direct access bvec table
Message-ID: <20170810111253.GA20308@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-2-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-2-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

I really don't think that these comments are all that useful.
A big comment near the bi_io_vec field defintion explaining the rules
for access would be a lot better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
