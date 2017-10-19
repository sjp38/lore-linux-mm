Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D24A36B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 18:56:23 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f187so8884967itb.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:56:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h18si8214575iob.175.2017.10.19.15.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 15:56:23 -0700 (PDT)
Date: Fri, 20 Oct 2017 06:55:56 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH v3 09/49] block: comment on bio_iov_iter_get_pages()
Message-ID: <20171019225555.GB27130@ming.t460p>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-10-ming.lei@redhat.com>
 <20170810112805.GE20308@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810112805.GE20308@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 04:28:05AM -0700, Christoph Hellwig wrote:
> > + * The hacking way of using bvec table as page pointer array is safe
> > + * even after multipage bvec is introduced because that space can be
> > + * thought as unused by bio_add_page().
> 
> I'm not sure what value this comment adds.
> 
> Note that once we have multi-page biovecs this could should change
> to take advantage of multipage biovecs, so adding a comment before
> that doesn't seem too helpful.

As mentioned in comment on patch 8, bio_alloc_pages() should be move
to bcache.

-- 
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
