Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A49876B0008
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:13:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t19-v6so1617666plo.9
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:13:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k190-v6si4110577pge.276.2018.06.27.11.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 11:13:58 -0700 (PDT)
Subject: Re: [PATCH V7 24/24] block: document usage of bio iterator helpers
References: <20180627124548.3456-1-ming.lei@redhat.com>
 <20180627124548.3456-25-ming.lei@redhat.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <98d6ba9d-ec7a-b05b-94bb-e798ad0e0ea7@infradead.org>
Date: Wed, 27 Jun 2018 11:13:45 -0700
MIME-Version: 1.0
In-Reply-To: <20180627124548.3456-25-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On 06/27/2018 05:45 AM, Ming Lei wrote:
> Now multipage bvec is supported, and some helpers may return page by
> page, and some may return segment by segment, this patch documents the
> usage for helping us use them correctly.
> 
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  Documentation/block/biovecs.txt | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
> index 25689584e6e0..f63af564ae89 100644
> --- a/Documentation/block/biovecs.txt
> +++ b/Documentation/block/biovecs.txt
> @@ -117,3 +117,30 @@ Other implications:
>     size limitations and the limitations of the underlying devices. Thus
>     there's no need to define ->merge_bvec_fn() callbacks for individual block
>     drivers.
> +
> +Usage of helpers:
> +=================
> +
> +* The following helpers which name has suffix of "_all" can only be used on

                   helpers whose names have the suffix of "_all" can only be used on

> +non-BIO_CLONED bio, and ususally they are used by filesystem code, and driver

                           usually

> +shouldn't use them becasue bio may have been splitted before they got to the

                      because                   split

> +driver:
> +
> +	bio_for_each_segment_all()
> +	bio_first_bvec_all()
> +	bio_first_page_all()
> +	bio_last_bvec_all()
> +
> +* The following helpers iterate over singlepage bvec, and the local

                   preferably:          single-page

> +variable of 'struct bio_vec' or the reference records single page io

                                                                     IO or I/O

> +vector during the itearation:
> +
> +	bio_for_each_segment()
> +	bio_for_each_segment_all()
> +
> +* The following helper iterates over multipage bvec, and each bvec may

                          preferably:   multi-page

> +include multiple physically contiguous pages, and the local variable of
> +'struct bio_vec' or the reference records multi page io vector during the

                                             multi-page IO or I/O

> +itearation:
> +
> +	bio_for_each_bvec()
> 


-- 
~Randy
