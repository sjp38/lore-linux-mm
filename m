Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06EE98E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:44:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 77-v6so1960361qkz.5
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:44:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x11-v6si979689qtf.296.2018.09.12.08.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 08:44:26 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] fs/dcache: Eliminate branches in
 nr_dentry_negative accounting
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-5-git-send-email-longman@redhat.com>
 <20180911221315.GH5631@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <c481718c-ab2b-040b-b4d4-efee3a6c2e1e@redhat.com>
Date: Wed, 12 Sep 2018 11:44:24 -0400
MIME-Version: 1.0
In-Reply-To: <20180911221315.GH5631@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 09/11/2018 06:13 PM, Dave Chinner wrote:
> On Tue, Sep 11, 2018 at 03:18:26PM -0400, Waiman Long wrote:
>> Because the accounting of nr_dentry_negative depends on whether a dentry
>> is a negative one or not, branch instructions are introduced to handle
>> the accounting conditionally. That may potentially slow down the task
>> by a noticeable amount if that introduces sizeable amount of additional
>> branch mispredictions.
>>
>> To avoid that, the accounting code is now modified to use conditional
>> move instructions instead, if supported by the architecture.
> I think this is a case of over-optimisation. It makes the code
> harder to read for extremely marginal benefit, and if we ever need
> to add any more code for negative dentries in these paths the first
> thing we'll have to do is revert this change.
>
> Unless you have numbers demonstrating that it's a clear performance
> improvement, then NACK for this patch.
>
> Cheers,
>
> Dave.

Yes, this is an optimization.

Unfortunately I don't have any performance number as I had not seen any
significant performance difference outside of the noise range with these
set of changes. I am not fine with not taking this patch.

Cheers,
Longman
