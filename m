Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1CE6B007E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 16:30:15 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so88229578pad.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:30:15 -0700 (PDT)
Received: from mail-pa0-f66.google.com (mail-pa0-f66.google.com. [209.85.220.66])
        by mx.google.com with ESMTPS id e5si7024499paf.167.2016.04.27.13.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 13:30:14 -0700 (PDT)
Received: by mail-pa0-f66.google.com with SMTP id zy2so6974329pac.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:30:14 -0700 (PDT)
Date: Wed, 27 Apr 2016 22:30:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1.2/2] mm: introduce memalloc_nofs_{save,restore} API
Message-ID: <20160427203010.GD22544@dhcp22.suse.cz>
References: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <1461758075-21815-1-git-send-email-mhocko@kernel.org>
 <1461758075-21815-2-git-send-email-mhocko@kernel.org>
 <20160427200927.GC22544@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427200927.GC22544@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Wed 27-04-16 22:09:27, Michal Hocko wrote:
[...]
> [   53.993480]   [<ffffffff810945e3>] mark_held_locks+0x5e/0x74
> [   53.993480]   [<ffffffff8109722c>] lockdep_trace_alloc+0xb2/0xb5
> [   53.993480]   [<ffffffff81174e56>] kmem_cache_alloc+0x36/0x2b0

Scratch that. I got it. It is the lockdep annotation which I got wrong
with my patch. I thought this was done much later in the slow path.
My head is burnt so I will get back to it tomorrow. The patch 1.1 should
be OK to go for XFS though because it doesn't really introduce anything
new.

Sorry about the noise!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
