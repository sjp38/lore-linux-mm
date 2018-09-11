Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4223F8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:02:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w18-v6so12102885plp.3
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:02:29 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id u10-v6si18122456pls.463.2018.09.11.15.02.27
        for <linux-mm@kvack.org>;
        Tue, 11 Sep 2018 15:02:28 -0700 (PDT)
Date: Wed, 12 Sep 2018 08:02:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 1/4] fs/dcache: Fix incorrect nr_dentry_unused
 accounting in shrink_dcache_sb()
Message-ID: <20180911220224.GE5631@dastard>
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-2-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536693506-11949-2-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Sep 11, 2018 at 03:18:23PM -0400, Waiman Long wrote:
> The nr_dentry_unused per-cpu counter tracks dentries in both the
> LRU lists and the shrink lists where the DCACHE_LRU_LIST bit is set.
> The shrink_dcache_sb() function moves dentries from the LRU list to a
> shrink list and subtracts the dentry count from nr_dentry_unused. This
> is incorrect as the nr_dentry_unused count Will also be decremented in
> shrink_dentry_list() via d_shrink_del(). To fix this double decrement,
> the decrement in the shrink_dcache_sb() function is taken out.
> 
> Fixes: 4e717f5c1083 ("list_lru: remove special case function list_lru_dispose_all."
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Please add a stable tag for this.

Otherwise looks fine.

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com
