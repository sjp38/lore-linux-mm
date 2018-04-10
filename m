Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E07FC6B0007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:27:14 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o33-v6so8732152plb.16
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 23:27:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6-v6si2031283plr.620.2018.04.09.23.27.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 23:27:14 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:27:10 +0200
From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH 4/7] block: pass explicit gfp_t to get_request
Message-ID: <20180410082710.7a9ddeb9@pentland.suse.de>
In-Reply-To: <20180409153916.23901-5-hch@lst.de>
References: <20180409153916.23901-1-hch@lst.de>
	<20180409153916.23901-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: axboe@kernel.dk, Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon,  9 Apr 2018 17:39:13 +0200
Christoph Hellwig <hch@lst.de> wrote:

> blk_old_get_request already has it at hand, and in blk_queue_bio,
> which is the fast path, it is constant.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/blk-core.c          | 14 +++++++-------
>  drivers/scsi/scsi_error.c |  4 ----
>  2 files changed, 7 insertions(+), 11 deletions(-)
> 
Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
