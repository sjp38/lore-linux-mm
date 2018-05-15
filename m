Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56B926B02BD
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:47:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o189-v6so2528831itc.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 09:47:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 72-v6sor542815itz.88.2018.05.15.09.47.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 May 2018 09:47:20 -0700 (PDT)
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-2-hch@lst.de>
 <20180509151243.GA1313@bombadil.infradead.org>
 <20180510064013.GA11422@lst.de>
 <AE0124C4-46F7-4051-BA24-AC2E3887E8A3@dilger.ca>
 <20180511062903.GA8210@lst.de>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <c9d1df5d-e9af-04f3-035c-29153a79b184@kernel.dk>
Date: Tue, 15 May 2018 10:47:16 -0600
MIME-Version: 1.0
In-Reply-To: <20180511062903.GA8210@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Andreas Dilger <adilger@dilger.ca>
Cc: Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On 5/11/18 12:29 AM, Christoph Hellwig wrote:
> On Thu, May 10, 2018 at 03:49:53PM -0600, Andreas Dilger wrote:
>> Would it make sense to change the bio_add_page() and bio_add_pc_page()
>> to use the more common convention instead of continuing the spread of
>> this non-standard calling convention?  This is doubly problematic since
>> "off" and "len" are both unsigned int values so it is easy to get them
>> mixed up, and just reordering the bio_add_page() arguments would not
>> generate any errors.
> 
> We have more than hundred callers.  I don't think we want to create
> so much churn just to clean things up a bit without any meaN?urable
> benefit.  And even if you want to clean it up I'd rather keep it
> away from my iomap/xfs buffered I/O series :)

Yeah let's not do that, I know someone that always gets really grumpy
when changes like that are made. So given that, I think we should retain
the argument order for that we already have for __bio_try_merge_page()
as well.

-- 
Jens Axboe
