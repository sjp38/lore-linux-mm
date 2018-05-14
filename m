Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECBDB6B000C
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:33:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y13-v6so9436561wrl.8
        for <linux-mm@kvack.org>; Mon, 14 May 2018 07:33:51 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r126-v6si5372671wmd.76.2018.05.14.07.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 07:33:50 -0700 (PDT)
Date: Mon, 14 May 2018 16:38:02 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: fix confusion around GFP_* flags and blk_get_request
Message-ID: <20180514143802.GA28197@lst.de>
References: <20180509075408.16388-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Jens, any comments?

On Wed, May 09, 2018 at 09:54:02AM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this series sorts out the mess around how we use gfp flags in the
> block layer get_request interface.
> 
> Changes since RFC:
>   - don't switch to GFP_NOIO for allocations in blk_get_request.
>     blk_get_request is used by the multipath code in potentially dead lock
>     prone areas, so this will need a separate audit and maybe a flag.
---end quoted text---
