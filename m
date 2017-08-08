Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB67F6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:35:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b66so31153085pfe.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:35:47 -0700 (PDT)
Received: from server.coly.li (server.coly.li. [162.144.45.48])
        by mx.google.com with ESMTPS id h8si874749pln.770.2017.08.08.05.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:35:46 -0700 (PDT)
Subject: Re: [PATCH v3 33/49] bcache: convert to bio_for_each_segment_all_sp()
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-34-ming.lei@redhat.com>
From: Coly Li <i@coly.li>
Message-ID: <f3b2bce7-53c2-7381-aaca-3d5e66b70d1d@coly.li>
Date: Tue, 8 Aug 2017 20:35:14 +0800
MIME-Version: 1.0
In-Reply-To: <20170808084548.18963-34-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-bcache@vger.kernel.org

On 2017/8/8 a,?a??4:45, Ming Lei wrote:
> Cc: linux-bcache@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@redhat.com>

The patch is good to me. Thanks.

Acked-by: Coly Li <colyli@suse.de>

> ---
>  drivers/md/bcache/btree.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> index 3da595ae565b..74cbb7387dc5 100644
> --- a/drivers/md/bcache/btree.c
> +++ b/drivers/md/bcache/btree.c
> @@ -422,8 +422,9 @@ static void do_btree_node_write(struct btree *b)
>  		int j;
>  		struct bio_vec *bv;
>  		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
> +		struct bvec_iter_all bia;
>  
> -		bio_for_each_segment_all(bv, b->bio, j)
> +		bio_for_each_segment_all_sp(bv, b->bio, j, bia)
>  			memcpy(page_address(bv->bv_page),
>  			       base + j * PAGE_SIZE, PAGE_SIZE);
>  
> 


-- 
Coly Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
