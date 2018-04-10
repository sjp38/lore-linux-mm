Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9CB26B0009
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:27:47 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az8-v6so4379151plb.2
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 23:27:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f64-v6si2013592plf.624.2018.04.09.23.27.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 23:27:46 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:27:45 +0200
From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH 5/7] block: use GFP_NOIO instead of __GFP_DIRECT_RECLAIM
Message-ID: <20180410082745.5b84ef48@pentland.suse.de>
In-Reply-To: <20180409153916.23901-6-hch@lst.de>
References: <20180409153916.23901-1-hch@lst.de>
	<20180409153916.23901-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: axboe@kernel.dk, Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon,  9 Apr 2018 17:39:14 +0200
Christoph Hellwig <hch@lst.de> wrote:

> We just can't do I/O when doing block layer requests allocations,
> so use GFP_NOIO instead of the even more limited __GFP_DIRECT_RECLAIM.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/blk-core.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 

Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
