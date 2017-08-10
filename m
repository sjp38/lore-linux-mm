Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1416B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:30:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o82so4030056pfj.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:30:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m39si563985plg.155.2017.08.10.04.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:30:06 -0700 (PDT)
Date: Thu, 10 Aug 2017 04:29:59 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 11/49] btrfs: avoid access to .bi_vcnt directly
Message-ID: <20170810112959.GG20308@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-12-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-12-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

> +static unsigned int get_bio_pages(struct bio *bio)
> +{
> +	unsigned i;
> +	struct bio_vec *bv;
> +
> +	bio_for_each_segment_all(bv, bio, i)
> +		;
> +
> +	return i;
> +}

s/get_bio_pages/bio_nr_pages/ ?

Also this seems like a useful helper for bio.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
