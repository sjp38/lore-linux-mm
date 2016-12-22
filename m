Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7492A6B0400
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 04:38:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id qs7so10296584wjc.4
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 01:38:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i7si31121752wjl.146.2016.12.22.01.38.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 01:38:33 -0800 (PST)
Date: Thu, 22 Dec 2016 10:38:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/9 v2] scope GFP_NOFS api
Message-ID: <20161222093828.GF6048@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215140715.12732-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>

Are there any objections to the approach and can we have this merged to
the mm tree?

Dave has expressed the patch2 should be dropped for now. I will do that
in a next submission but I do not want to resubmit until there is a
consensus on this.

What do other than xfs/ext4 developers think about this API. Can we find
a way to use it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
