Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 391076B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 12:13:58 -0400 (EDT)
Received: by wizk4 with SMTP id k4so61149543wiz.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 09:13:57 -0700 (PDT)
Date: Wed, 8 Apr 2015 18:13:55 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2][v2] blk-plug: don't flush nested plug lists
Message-ID: <20150408161355.GA16052@lst.de>
References: <1428347694-17704-1-git-send-email-jmoyer@redhat.com> <1428347694-17704-2-git-send-email-jmoyer@redhat.com> <x49wq1nrcoe.fsf_-_@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49wq1nrcoe.fsf_-_@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Roger Pau Monn?? <roger.pau@citrix.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Steven Whitehouse <swhiteho@redhat.com>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, Christoph Hellwig <hch@lst.de>, Weston Andros Adamson <dros@primarydata.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Sagi Grimberg <sagig@mellanox.com>, Tejun Heo <tj@kernel.org>, Fabian Frederick <fabf@skynet.be>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ming Lei <ming.lei@canonical.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Wang Sheng-Hui <shhuiw@gmail.com>, Michal Hocko <mhocko@suse.cz>, Joe Perches <joe@perches.com>, Miklos Szeredi <mszeredi@suse.cz>, Namjae Jeon <namjae.jeon@samsung.com>, Mark Rustad <mark.d.rustad@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-kernel@vger.kernel.org, dm-devel@redhat.com, xen-devel@lists.xenproject.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

This looks good, but without the blk_finish_plug argument we're bound
to grow programming mistakes where people forget it.  Any chance we
could have annotations similar to say rcu_read_lock/rcu_read_unlock
or the spinlocks so that sparse warns about it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
