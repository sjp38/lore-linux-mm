Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9056B000D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:20:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z5-v6so10547073pfz.6
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:20:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w28-v6si24887211pge.329.2018.06.11.10.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 10:19:59 -0700 (PDT)
Date: Mon, 11 Jun 2018 10:19:38 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 08/30] block: introduce chunk_last_segment()
Message-ID: <20180611171938.GA5101@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-9-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180609123014.8861-9-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

I think both callers would be just as easy to understand by using
nth_page() instead of these magic helpers.  E.g. for guard_bio_eod:

		unsigned offset = (bv.bv_offset + bv.bv_len);
		struct page *page = nth_page(bv.bv_page, offset);

		zero_user(page, offset & PAGE_MASK, truncated_bytes);
