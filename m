Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F191D8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:41:54 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t9-v6so1952934qkl.2
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:41:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d3-v6si1069995qtg.117.2018.09.12.08.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 08:41:54 -0700 (PDT)
Subject: Re: [PATCH v3 1/4] fs/dcache: Fix incorrect nr_dentry_unused
 accounting in shrink_dcache_sb()
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-2-git-send-email-longman@redhat.com>
 <20180911220224.GE5631@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <538489aa-d021-5662-7a46-d358f8770054@redhat.com>
Date: Wed, 12 Sep 2018 11:41:52 -0400
MIME-Version: 1.0
In-Reply-To: <20180911220224.GE5631@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 09/11/2018 06:02 PM, Dave Chinner wrote:
> On Tue, Sep 11, 2018 at 03:18:23PM -0400, Waiman Long wrote:
>> The nr_dentry_unused per-cpu counter tracks dentries in both the
>> LRU lists and the shrink lists where the DCACHE_LRU_LIST bit is set.
>> The shrink_dcache_sb() function moves dentries from the LRU list to a
>> shrink list and subtracts the dentry count from nr_dentry_unused. This
>> is incorrect as the nr_dentry_unused count Will also be decremented in
>> shrink_dentry_list() via d_shrink_del(). To fix this double decrement,
>> the decrement in the shrink_dcache_sb() function is taken out.
>>
>> Fixes: 4e717f5c1083 ("list_lru: remove special case function list_lru_dispose_all."
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> Please add a stable tag for this.
>
> Otherwise looks fine.
>
> Reviewed-by: Dave Chinner <dchinner@redhat.com>
>
I will add the cc:stable tag.

Cheers,
Longman
