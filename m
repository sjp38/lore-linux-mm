Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4508E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:02:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22-v6so12066734plq.21
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:02:49 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id w2-v6si22736191pgh.182.2018.09.11.15.02.47
        for <linux-mm@kvack.org>;
        Tue, 11 Sep 2018 15:02:47 -0700 (PDT)
Date: Wed, 12 Sep 2018 08:02:44 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 2/4] fs: Don't need to put list_lru into its own
 cacheline
Message-ID: <20180911220244.GF5631@dastard>
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-3-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536693506-11949-3-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Sep 11, 2018 at 03:18:24PM -0400, Waiman Long wrote:
> The list_lru structure is essentially just a pointer to a table of
> per-node LRU lists. Even if CONFIG_MEMCG_KMEM is defined, the list
> field is just used for LRU list registration and shrinker_id is set
> at initialization. Those fields won't need to be touched that often.
> 
> So there is no point to make the list_lru structures to sit in their
> own cachelines.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Looks fine.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
