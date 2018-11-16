Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59C7D6B0A68
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:40:33 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so11159591plt.7
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:40:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor35712556pgq.25.2018.11.16.08.40.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 08:40:32 -0800 (PST)
Date: Fri, 16 Nov 2018 08:40:28 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 18/19] block: kill QUEUE_FLAG_NO_SG_MERGE
Message-ID: <20181116164028.GW23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-19-ming.lei@redhat.com>
 <20181116021811.GM23828@vader>
 <20181116135922.GO3165@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116135922.GO3165@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 02:59:22PM +0100, Christoph Hellwig wrote:
> On Thu, Nov 15, 2018 at 06:18:11PM -0800, Omar Sandoval wrote:
> > This commit message wasn't very clear. Is it the case that
> > QUEUE_FLAG_NO_SG_MERGE is no longer set by any drivers?
> 
> I think he wants to say that not doing S/G merging is rather pointless
> with the current setup of the I/O path, as it isn't going to save
> you a significant amount of cycles.

Okay, that makes sense. Ming, you can add

Reviewed-by: Omar Sandoval <osandov@fb.com>
