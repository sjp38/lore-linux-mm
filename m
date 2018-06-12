Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4566B0010
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 23:24:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a16-v6so20630920qkb.7
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 20:24:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e26-v6si5248859qvb.180.2018.06.11.20.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 20:24:38 -0700 (PDT)
Date: Tue, 12 Jun 2018 11:24:20 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 08/30] block: introduce chunk_last_segment()
Message-ID: <20180612032419.GB26412@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-9-ming.lei@redhat.com>
 <20180611171938.GA5101@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180611171938.GA5101@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Mon, Jun 11, 2018 at 10:19:38AM -0700, Christoph Hellwig wrote:
> I think both callers would be just as easy to understand by using
> nth_page() instead of these magic helpers.  E.g. for guard_bio_eod:
> 
> 		unsigned offset = (bv.bv_offset + bv.bv_len);
> 		struct page *page = nth_page(bv.bv_page, offset);

The above lines should have been written as:

		struct page *page = nth_page(bv.bv_page, offset / PAGE_SIZE)

but this way may cause 'page' points to the next page of bv's last
page if offset == N * PAGE_SIZE.


Thanks,
Ming
