Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4923C6B0007
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 02:19:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 69-v6so1750403pgg.0
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 23:19:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x2-v6si4315330pfn.315.2018.06.13.23.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 23:19:09 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:18:59 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180614061858.GA3336@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180611164806.GA7452@infradead.org>
 <20180612034242.GC26412@ming.t460p>
 <20180613144253.GA4693@infradead.org>
 <20180614011852.GA19828@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180614011852.GA19828@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Thu, Jun 14, 2018 at 09:18:58AM +0800, Ming Lei wrote:
> This one may cause confusing, since we iterate over pages via
> bio_for_each_segment(), but the _all version takes another name
> of page, still iterate over pages.
> 
> So could we change it in the following way?
> 
>  OLD:	    bio_for_each_segment_all
>  NEW(page): bio_for_each_segment_all (update prototype in one tree-wide &
>  			big patch, to be renamed bio_for_each_page_all)
>  NEW(bvec):  (no bvec version needed once bcache is fixed up)	

Fine with me, but I thought Jens didn't like that sweeping change?
