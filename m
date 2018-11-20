Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E44006B1D6D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 19:49:33 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id g204-v6so127118oia.21
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:49:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor8770536oik.158.2018.11.19.16.49.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 16:49:32 -0800 (PST)
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-10-ming.lei@redhat.com> <20181116134541.GH3165@lst.de>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
Date: Mon, 19 Nov 2018 16:49:27 -0800
MIME-Version: 1.0
In-Reply-To: <20181116134541.GH3165@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


> The only user in your final tree seems to be the loop driver, and
> even that one only uses the helper for read/write bios.
> 
> I think something like this would be much simpler in the end:

The recently submitted nvme-tcp host driver should also be a user
of this. Does it make sense to keep it as a helper then?
