Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2966B0643
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:56:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t5-v6so5371499ply.13
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:56:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 7-v6sor3473383pft.128.2018.05.18.09.56.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 09:56:56 -0700 (PDT)
Subject: Re: [PATCH 01/34] block: add a lower-level bio_add_page interface
References: <20180518164830.1552-1-hch@lst.de>
 <20180518164830.1552-2-hch@lst.de>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <febbcb2b-b3de-4e43-242e-0eb43f681bd0@kernel.dk>
Date: Fri, 18 May 2018 10:56:53 -0600
MIME-Version: 1.0
In-Reply-To: <20180518164830.1552-2-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On 5/18/18 10:47 AM, Christoph Hellwig wrote:
> For the upcoming removal of buffer heads in XFS we need to keep track of
> the number of outstanding writeback requests per page.  For this we need
> to know if bio_add_page merged a region with the previous bvec or not.
> Instead of adding additional arguments this refactors bio_add_page to
> be implemented using three lower level helpers which users like XFS can
> use directly if they care about the merge decisions.

Reviewed-by: Jens Axboe <axboe@kernel.dk>

-- 
Jens Axboe
