Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC0B66B0313
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:22:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s65so5805928pfi.14
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:22:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h6si1821756pfg.189.2017.06.15.01.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 01:22:44 -0700 (PDT)
Date: Thu, 15 Jun 2017 01:22:21 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 12/20] fs: add a new fstype flag to indicate how
 writeback errors are tracked
Message-ID: <20170615082221.GA22809@infradead.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
 <20170612122316.13244-15-jlayton@redhat.com>
 <20170612124513.GC18360@infradead.org>
 <1497349472.5762.1.camel@redhat.com>
 <20170614064731.GB3598@infradead.org>
 <1497461083.6752.7.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497461083.6752.7.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Wed, Jun 14, 2017 at 01:24:43PM -0400, Jeff Layton wrote:
> In this smaller set, it's only really used for DAX.

DAX only is implemented by three filesystems, please just fix them
up in one go.

> sync_file_range: ->fsync isn't called directly there, and I think we
> probably want similar semantics to fsync() for it

sync_file_range is only supposed to sync data, so it should not call
->fsync.

> JBD2: will try to re-set the error after clearing it with
> filemap_fdatawait. That's problematic with the new infrastructure so we
> need some way to avoid it.

JBD2 only has two users, please fix them up in one go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
