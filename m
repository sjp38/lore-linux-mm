Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7743F6B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 08:01:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v36so3941204pgn.6
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 05:01:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p85si5120159pfa.407.2017.06.24.05.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 05:01:00 -0700 (PDT)
Date: Sat, 24 Jun 2017 04:59:46 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v7 16/22] block: convert to errseq_t based writeback
 error tracking
Message-ID: <20170624115946.GA22561@infradead.org>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-17-jlayton@redhat.com>
 <20170620123544.GC19781@infradead.org>
 <1497980684.4555.16.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497980684.4555.16.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Tue, Jun 20, 2017 at 01:44:44PM -0400, Jeff Layton wrote:
> In order to query for errors with errseq_t, you need a previously-
> sampled point from which to check. When you call
> filemap_write_and_wait_range though you don't have a struct file and so
> no previously-sampled value.

So can we simply introduce variants of them that take a struct file?
That would be:

 a) less churn
 b) less code
 c) less chance to get data integrity wrong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
