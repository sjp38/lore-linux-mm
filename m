Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 640E56B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 21:27:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c87so7844834pfl.6
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 18:27:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l12si4748703plc.299.2017.03.24.18.27.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 18:27:35 -0700 (PDT)
Subject: Re: [PATCH] hugetlbfs: initialize shared policy as part of inode allocation
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1490397106-11101-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1490397106-11101-1-git-send-email-mike.kravetz@oracle.com>
Message-Id: <201703250954.ICG12429.FHOMFLJOSOtFQV@I-love.SAKURA.ne.jp>
Date: Sat, 25 Mar 2017 09:54:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, mhocko@suse.com, hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, akpm@linux-foundation.org

Mike Kravetz wrote:
> Any time after inode allocation, destroy_inode can be called.  The
> hugetlbfs inode contains a shared_policy structure, and
> mpol_free_shared_policy is unconditionally called as part of
> hugetlbfs_destroy_inode.  Initialize the policy as part of inode
> allocation so that any quick (error path) calls to destroy_inode
> will be handed an initialized policy.

I think you can as well do

-		struct hugetlbfs_inode_info *info;
-		info = HUGETLBFS_I(inode);
-		mpol_shared_policy_init(&info->policy, NULL);

in hugetlbfs_get_root().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
