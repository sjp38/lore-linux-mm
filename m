Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3D636B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:54:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n190-v6so14053578itg.4
        for <linux-mm@kvack.org>; Mon, 14 May 2018 07:54:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d3-v6sor5581255ite.85.2018.05.14.07.54.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 07:54:30 -0700 (PDT)
Subject: Re: fix confusion around GFP_* flags and blk_get_request
References: <20180509075408.16388-1-hch@lst.de>
 <20180514143802.GA28197@lst.de>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <b069a7b0-62e5-baae-dbd3-6e4cf4db9742@kernel.dk>
Date: Mon, 14 May 2018 08:54:27 -0600
MIME-Version: 1.0
In-Reply-To: <20180514143802.GA28197@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On 5/14/18 8:38 AM, Christoph Hellwig wrote:
> Jens, any comments?

Looks good to me.

-- 
Jens Axboe
