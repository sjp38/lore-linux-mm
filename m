Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0EE6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:01:36 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id b205so22286284wmb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:01:36 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id g139si2975277wmd.7.2016.02.25.01.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 01:01:34 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id c200so18223508wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:01:34 -0800 (PST)
Subject: Re: [PATCH RFC] ext4: use __GFP_NOFAIL in ext4_free_blocks()
References: <20160224170912.2195.8153.stgit@buzz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <56CEC2EC.5000506@kyup.com>
Date: Thu, 25 Feb 2016 11:01:32 +0200
MIME-Version: 1.0
In-Reply-To: <20160224170912.2195.8153.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Theodore Ts'o <tytso@mit.edu>
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Monakhov <dmonakhov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org



On 02/24/2016 07:09 PM, Konstantin Khlebnikov wrote:
> This might be unexpected but pages allocated for sbi->s_buddy_cache are
> charged to current memory cgroup. So, GFP_NOFS allocation could fail if
> current task has been killed by OOM or if current memory cgroup has no
> free memory left. Block allocator cannot handle such failures here yet.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Adding new users of GFP_NOFAIL is deprecated. Where exactly does the
block allocator fail, I skimmed the code and failing ext4_mb_load_buddy
seems to be handled at all call sites. There are some BUG_ONs but from
the comments there I guess they should occur when we try to find a page
and not allocate a new one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
