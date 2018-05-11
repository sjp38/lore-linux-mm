Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58E2A6B065B
	for <linux-mm@kvack.org>; Fri, 11 May 2018 02:25:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 142-v6so287651wmt.1
        for <linux-mm@kvack.org>; Thu, 10 May 2018 23:25:19 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e76-v6si418223wme.17.2018.05.10.23.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 23:25:18 -0700 (PDT)
Date: Fri, 11 May 2018 08:29:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
Message-ID: <20180511062903.GA8210@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-2-hch@lst.de> <20180509151243.GA1313@bombadil.infradead.org> <20180510064013.GA11422@lst.de> <AE0124C4-46F7-4051-BA24-AC2E3887E8A3@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AE0124C4-46F7-4051-BA24-AC2E3887E8A3@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, axboe@kernel.dk

On Thu, May 10, 2018 at 03:49:53PM -0600, Andreas Dilger wrote:
> Would it make sense to change the bio_add_page() and bio_add_pc_page()
> to use the more common convention instead of continuing the spread of
> this non-standard calling convention?  This is doubly problematic since
> "off" and "len" are both unsigned int values so it is easy to get them
> mixed up, and just reordering the bio_add_page() arguments would not
> generate any errors.

We have more than hundred callers.  I don't think we want to create
so much churn just to clean things up a bit without any meaN?urable
benefit.  And even if you want to clean it up I'd rather keep it
away from my iomap/xfs buffered I/O series :)

> One option would be to rename this function bio_page_add() so there are
> build errors or first add bio_page_add() and mark bio_add_page()
> deprecated and allow some short time for transition?  There are about
> 50 uses under drivers/ and 50 uses under fs/.

If you think the churn is worthwhile send a separate series for that.
My two new functions should have very few callers even by then, so
feel free to just update them as well.
