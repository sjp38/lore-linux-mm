Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBE836B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:01:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 123so5049891pga.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:01:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n10si3854964pgc.265.2017.08.10.05.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 05:01:51 -0700 (PDT)
Date: Thu, 10 Aug 2017 05:01:46 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 19/49] block: implement sp version of bvec iterator
 helpers
Message-ID: <20170810120146.GB14607@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-20-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-20-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 08, 2017 at 04:45:18PM +0800, Ming Lei wrote:
> This patch implements singlepage version of the following
> 3 helpers:
> 	- bvec_iter_offset_sp()
> 	- bvec_iter_len_sp()
> 	- bvec_iter_page_sp()
> 
> So that one multipage bvec can be splited to singlepage
> bvec, and make users of current bvec iterator happy.

Please merge this into the previous patch, and keep the existing
non postfixed names for the single page version, and use
bvec_iter_segment_* for the multipage versions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
