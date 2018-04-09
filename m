Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 155CA6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:39:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c85so5187808pfb.12
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:39:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f4-v6si525358plr.352.2018.04.09.08.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 08:39:23 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [RFC] fix confusion around GFP_* flags and blk_get_request
Date: Mon,  9 Apr 2018 17:39:09 +0200
Message-Id: <20180409153916.23901-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Hi all,

this series sorts out the mess around how we use gfp flags in the
block layer get_request interface.
