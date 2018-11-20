Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6588E6B20D0
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 11:16:54 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y85so4271602wmc.7
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:16:54 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d64si15517884wmc.146.2018.11.20.08.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 08:16:52 -0800 (PST)
Date: Tue, 20 Nov 2018 17:16:51 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
Message-ID: <20181120161651.GB2629@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-10-ming.lei@redhat.com> <20181116134541.GH3165@lst.de> <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 19, 2018 at 04:49:27PM -0800, Sagi Grimberg wrote:
>
>> The only user in your final tree seems to be the loop driver, and
>> even that one only uses the helper for read/write bios.
>>
>> I think something like this would be much simpler in the end:
>
> The recently submitted nvme-tcp host driver should also be a user
> of this. Does it make sense to keep it as a helper then?

I did take a brief look at the code, and I really don't understand
why the heck it even deals with bios to start with.  Like all the
other nvme transports it is a blk-mq driver and should iterate
over segments in a request and more or less ignore bios.  Something
is horribly wrong in the design.
