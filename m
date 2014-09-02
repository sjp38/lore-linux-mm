Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8006B6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 07:33:28 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 20so3964040yks.18
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 04:33:28 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [74.207.234.97])
        by mx.google.com with ESMTPS id n43si7023582yhd.108.2014.09.02.04.33.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 04:33:28 -0700 (PDT)
Date: Tue, 2 Sep 2014 07:31:04 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: ext4 vs btrfs performance on SSD array
Message-ID: <20140902113104.GD5049@thunk.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
 <20140902000822.GA20473@dastard>
 <20140902012222.GA21405@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140902012222.GA21405@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Nikolai Grigoriev <ngrigoriev@gmail.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

>  - the very small max readahead size

For things like the readahead size, that's probably something that we
should autotune, based the time it takes to read N sectors.  i.e.,
start N relatively small, such as 128k, and then bump it up based on
how long it takes to do a sequential read of N sectors until it hits a
given tunable, which is specified in milliseconds instead of kilobytes.

>  - replacing cfq with deadline (or noop)

Unfortunately, that will break ionice and a number of other things...

      	       	     		     		  - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
