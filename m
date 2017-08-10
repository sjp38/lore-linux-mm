Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C68E46B02C3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:16:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a186so4006698pge.7
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:16:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q1si4287337plb.12.2017.08.10.04.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:16:22 -0700 (PDT)
Date: Thu, 10 Aug 2017 04:16:16 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 05/49] fs/buffer: comment on direct access to bvec
 table
Message-ID: <20170810111616.GC20308@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-6-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-6-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

> +	/*
> +	 * It is safe to truncate the last bvec in the following way
> +	 * even though multipage bvec is supported, but we need to
> +	 * fix the parameters passed to zero_user().
> +	 */
> +	struct bio_vec *bvec = &bio->bi_io_vec[bio->bi_vcnt - 1];

A 'we need to fix XXX' comment isn't very useful.  Just fix it in the
series (which I suspect you're going to do anyway).

Also a bio_last_vec helper might be nice for something like this and
documents properly converted places much better than these comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
