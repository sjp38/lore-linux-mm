Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90CF26B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 02:40:24 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so25325350pga.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 23:40:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b14si6767204pfe.412.2017.09.26.23.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 23:40:23 -0700 (PDT)
Date: Tue, 26 Sep 2017 23:40:01 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20170927064001.GA27601@infradead.org>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-2-ross.zwisler@linux.intel.com>
 <20170925233812.GM10955@dastard>
 <20170926093548.GB13627@quack2.suse.cz>
 <20170926110957.GR10955@dastard>
 <20170926143743.GB18758@lst.de>
 <20170926173057.GB20159@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926173057.GB20159@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dan Williams <dan.j.williams@intel.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 11:30:57AM -0600, Ross Zwisler wrote:
> I agree that Christoph's idea about having the system intelligently adjust to
> use DAX based on performance information it gathers about the underlying
> persistent memory (probably via the HMAT on x86_64 systems) is interesting,
> but I think we're still a ways away from that.

So what are the missing blockers for a getting started?

> FWIW, as my patches suggest and Jan observed I think that we should allow
> users to turn on DAX by treating the inode flag and the mount flag as an 'or'
> operation.  i.e. you get DAX if either the mount option is specified or if the
> inode flag is set, and you can continue to manipulate the per-inode flag as
> you want regardless of the mount option.  I think this provides maximum
> flexibility of the mechanism to select DAX without enforcing policy.

IFF we stick to the dax flag that's the only workable way.  The only
major issue I still see with that is that this allows unprivilegued
users to enable DAX on a any file they own / have write access to.
So there isn't really any way to effectively disable the DAX path
by the sysadmin.

> Does it make sense at this point to just start a "dax" man page that can
> contain info about the mount options, inode flags, kernel config options, how
> to get PMDs, etc?  Or does this documentation need to be sprinkled around more
> in existing man pages?

A dax manpage would be good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
