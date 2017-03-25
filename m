Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B40A26B0038
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 17:36:06 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id a6so9207235vkh.1
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 14:36:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u67si2586915vkg.194.2017.03.25.14.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Mar 2017 14:36:05 -0700 (PDT)
Subject: Re: [PATCH] hugetlbfs: initialize shared policy as part of inode
 allocation
References: <1490397106-11101-1-git-send-email-mike.kravetz@oracle.com>
 <201703250954.ICG12429.FHOMFLJOSOtFQV@I-love.SAKURA.ne.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <16be9b63-5325-771f-25dd-7fd9e0c67866@oracle.com>
Date: Sat, 25 Mar 2017 14:35:53 -0700
MIME-Version: 1.0
In-Reply-To: <201703250954.ICG12429.FHOMFLJOSOtFQV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, mhocko@suse.com, hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, akpm@linux-foundation.org

On 03/24/2017 05:54 PM, Tetsuo Handa wrote:
> Mike Kravetz wrote:
>> Any time after inode allocation, destroy_inode can be called.  The
>> hugetlbfs inode contains a shared_policy structure, and
>> mpol_free_shared_policy is unconditionally called as part of
>> hugetlbfs_destroy_inode.  Initialize the policy as part of inode
>> allocation so that any quick (error path) calls to destroy_inode
>> will be handed an initialized policy.
> 
> I think you can as well do
> 
> -		struct hugetlbfs_inode_info *info;
> -		info = HUGETLBFS_I(inode);
> -		mpol_shared_policy_init(&info->policy, NULL);
> 
> in hugetlbfs_get_root().

Thank you.  You are correct.
After doing shared policy initialization at inode allocation time,
it is redundant here.

I will send v2 patch with this modification.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
