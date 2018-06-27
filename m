Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30E696B0269
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:17:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 5-v6so1968476qta.1
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:17:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a17-v6si3860400qtp.143.2018.06.27.06.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 06:17:13 -0700 (PDT)
Date: Wed, 27 Jun 2018 09:17:11 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [PATCH V7 01/24] dm: use bio_split() when splitting out the
 already processed bio
Message-ID: <20180627131711.GA11531@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
 <20180627124548.3456-2-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627124548.3456-2-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, stable@vger.kernel.org

On Wed, Jun 27 2018 at  8:45am -0400,
Ming Lei <ming.lei@redhat.com> wrote:

> From: Mike Snitzer <snitzer@redhat.com>
> 
> Use of bio_clone_bioset() is inefficient if there is no need to clone
> the original bio's bio_vec array.  Best to use the bio_clone_fast()
> variant.  Also, just using bio_advance() is only part of what is needed
> to properly setup the clone -- it doesn't account for the various
> bio_integrity() related work that also needs to be performed (see
> bio_split).
> 
> Address both of these issues by switching from bio_clone_bioset() to
> bio_split().
> 
> Fixes: 18a25da8 ("dm: ensure bio submission follows a depth-first tree walk")
> Cc: stable@vger.kernel.org
> Reported-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: NeilBrown <neilb@suse.com>
> Reviewed-by: Ming Lei <ming.lei@redhat.com>
> Signed-off-by: Mike Snitzer <snitzer@redhat.com>

FYI, I'll be sending this to Linus tomorrow.

Mike
