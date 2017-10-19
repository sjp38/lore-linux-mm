Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D30BA6B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 18:57:58 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j140so8891774itj.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:57:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h68si2084168itg.56.2017.10.19.15.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 15:57:58 -0700 (PDT)
Date: Fri, 20 Oct 2017 06:57:44 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH v3 11/49] btrfs: avoid access to .bi_vcnt directly
Message-ID: <20171019225743.GC27130@ming.t460p>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-12-ming.lei@redhat.com>
 <20170810112959.GG20308@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810112959.GG20308@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

On Thu, Aug 10, 2017 at 04:29:59AM -0700, Christoph Hellwig wrote:
> > +static unsigned int get_bio_pages(struct bio *bio)
> > +{
> > +	unsigned i;
> > +	struct bio_vec *bv;
> > +
> > +	bio_for_each_segment_all(bv, bio, i)
> > +		;
> > +
> > +	return i;
> > +}
> 
> s/get_bio_pages/bio_nr_pages/ ?

Yeah, the name of bio_nr_pages() is much better.

> 
> Also this seems like a useful helper for bio.h

OK.


-- 
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
