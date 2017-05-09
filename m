Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40F882806E3
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:33:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c75so1422517qka.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:33:08 -0700 (PDT)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id m41si239678qtc.237.2017.05.09.08.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:33:07 -0700 (PDT)
Received: by mail-qk0-f173.google.com with SMTP id a72so4074988qkj.2
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:33:07 -0700 (PDT)
Message-ID: <1494343983.2659.7.camel@redhat.com>
Subject: Re: [RFC xfstests PATCH] xfstests: add a writeback error handling
 test
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 09 May 2017 11:33:03 -0400
In-Reply-To: <20170424150019.GA3288@infradead.org>
References: <20170424134551.10301-1-jlayton@redhat.com>
	 <20170424150019.GA3288@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: fstests@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon, 2017-04-24 at 08:00 -0700, Christoph Hellwig wrote:
> On Mon, Apr 24, 2017 at 09:45:51AM -0400, Jeff Layton wrote:
> > With the patch series above, ext4 now passes. xfs and btrfs end up in
> > r/o mode after the test. xfs returns -EIO at that point though, and
> > btrfs returns -EROFS. What behavior we actually want there, I'm not
> > certain. We might be able to mitigate that by putting the journals on a
> > separate device?
> 
> This looks like XFS shut down because of a permanent write error from
> dm-error.  Which seems like the expected behavior.

Oops, didn't see this message earlier...

Yeah, that's entirely reasonable when there is a write error to the
journal. The latest version of this uses $SCRATCH_LOGDEV to put the
journal on a different device, and with that I get the expected behavior
from xfs.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
