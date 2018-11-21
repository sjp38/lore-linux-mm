Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E91106B240A
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:42:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so5794156ply.4
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:42:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor11678969pgl.1.2018.11.20.20.42.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 20:42:07 -0800 (PST)
Subject: Re: [PATCH V10 09/19] block: introduce bio_bvecs()
From: Sagi Grimberg <sagi@grimberg.me>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-10-ming.lei@redhat.com> <20181116134541.GH3165@lst.de>
 <002fe56b-25e4-573e-c09b-bb12c3e8d25a@grimberg.me>
 <20181120161651.GB2629@lst.de>
 <53526aae-fb9b-ee38-0a01-e5899e2d4e4d@grimberg.me>
 <20181121005902.GA31748@ming.t460p>
 <2d9bee7a-f010-dcf4-1184-094101058584@grimberg.me>
 <20181121034415.GA8408@ming.t460p>
 <2a47d336-c19b-6bf4-c247-d7382871eeea@grimberg.me>
Message-ID: <7378bf49-5a7e-5622-d4d1-808ba37ce656@grimberg.me>
Date: Tue, 20 Nov 2018 20:42:04 -0800
MIME-Version: 1.0
In-Reply-To: <2a47d336-c19b-6bf4-c247-d7382871eeea@grimberg.me>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com


>> Yeah, that is the most common example, given merge is enabled
>> in most of cases. If the driver or device doesn't care merge,
>> you can disable it and always get single bio request, then the
>> bio's bvec table can be reused for send().
> 
> Does bvec_iter span bvecs with your patches? I didn't see that change?

Wait, I see that the bvec is still a single array per bio. When you said
a table I thought you meant a 2-dimentional array...

Unless I'm not mistaken, I think that the change is pretty simple then.
However, nvme-tcp still needs to be bio aware unless we have some
abstraction in place.. Which will mean that nvme-tcp will need to
open-code bio_bvecs.
