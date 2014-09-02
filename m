Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6B26B003C
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 10:20:28 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id w7so7601471lbi.39
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 07:20:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kn13si5265663lbb.3.2014.09.02.07.20.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 07:20:26 -0700 (PDT)
Date: Tue, 2 Sep 2014 16:20:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: ext4 vs btrfs performance on SSD array
Message-ID: <20140902142024.GB19412@quack.suse.cz>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
 <20140902000822.GA20473@dastard>
 <20140902012222.GA21405@infradead.org>
 <20140902113104.GD5049@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140902113104.GD5049@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Nikolai Grigoriev <ngrigoriev@gmail.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

On Tue 02-09-14 07:31:04, Ted Tso wrote:
> >  - the very small max readahead size
> 
> For things like the readahead size, that's probably something that we
> should autotune, based the time it takes to read N sectors.  i.e.,
> start N relatively small, such as 128k, and then bump it up based on
> how long it takes to do a sequential read of N sectors until it hits a
> given tunable, which is specified in milliseconds instead of kilobytes.
  Actually the amount of readahead we do is autotuned (based on hit rate).
So I would keep the setting in sysfs as the maximum size adaptive readahead
can ever read and we can bump it up. We can possibly add another feedback
into the readahead code to tune actualy readahead size depending on device
speed but we'd have to research exactly what algorithm would work best.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
