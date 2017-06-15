Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEC4B6B02F3
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:03:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n40so12976423qtb.4
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:03:29 -0700 (PDT)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com. [209.85.216.182])
        by mx.google.com with ESMTPS id d82si338862qkg.309.2017.06.15.08.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 08:03:28 -0700 (PDT)
Received: by mail-qt0-f182.google.com with SMTP id u12so24013759qth.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:03:28 -0700 (PDT)
Message-ID: <1497539004.4607.7.camel@redhat.com>
Subject: Re: [PATCH v6 12/20] fs: add a new fstype flag to indicate how
 writeback errors are tracked
From: Jeff Layton <jlayton@redhat.com>
Date: Thu, 15 Jun 2017 11:03:24 -0400
In-Reply-To: <20170615145724.GB14028@infradead.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
	 <20170612122316.13244-15-jlayton@redhat.com>
	 <20170612124513.GC18360@infradead.org> <1497349472.5762.1.camel@redhat.com>
	 <20170614064731.GB3598@infradead.org> <1497461083.6752.7.camel@redhat.com>
	 <20170615082221.GA22809@infradead.org> <1497523332.4556.1.camel@redhat.com>
	 <20170615145724.GB14028@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Thu, 2017-06-15 at 07:57 -0700, Christoph Hellwig wrote:
> On Thu, Jun 15, 2017 at 06:42:12AM -0400, Jeff Layton wrote:
> > Correct.
> > 
> > But if there is a data writeback error, should we report an error on all
> > open fds at that time (like we will for fsync)?
> 
> We should in theory, but I don't see how to properly do it.  In addition
> sync_file_range just can't be used for data integrity to start with, so
> I don't think it's worth it.  At some point we should add a proper
> fsync_range syscall, though.

filemap_report_wb_err will always return 0 if the inode never has
mapping_set_error called on it. So, I think we should be able to do it
there once we get all of the fs' converted over. That'll have to happen
at the end of the series however.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
