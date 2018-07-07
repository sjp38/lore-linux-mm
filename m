Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7C436B0006
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 23:02:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c3-v6so15681348qkb.2
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 20:02:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l35-v6si9414132qvg.30.2018.07.06.20.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 20:02:25 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180706222814.GE30522@ZenIV.linux.org.uk>
From: Waiman Long <longman@redhat.com>
Message-ID: <56b1d7ee-d362-f915-34fb-92173d512cbe@redhat.com>
Date: Fri, 6 Jul 2018 23:02:23 -0400
MIME-Version: 1.0
In-Reply-To: <20180706222814.GE30522@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/06/2018 06:28 PM, Al Viro wrote:
> On Fri, Jul 06, 2018 at 03:32:45PM -0400, Waiman Long wrote:
>
>> With a 4.18 based kernel, the positive & negative dentries lookup rates
>> (lookups per second) after initial boot on a 2-socket 24-core 48-thread
>> 64GB memory system with and without the patch were as follows: `
>>
>>   Metric                    w/o patch  neg_dentry_pc=0  neg_dentry_pc=1
>>   ------                    ---------  ---------------  ---------------
>>   Positive dentry lookup      584299       586749	   582670
>>   Negative dentry lookup     1422204      1439994	  1438440
>>   Negative dentry creation    643535       652194	   641841
>>
>> For the lookup rate, there isn't any signifcant difference with or
>> without the patch or with a zero or non-zero value of neg_dentry_pc.
> Sigh...  What I *still* don't see (after all the iterations of the patchset)
> is any performance data on workloads that would be likely to feel the impact.
> Anything that seriously hits INCLUDE_PATH, for starters...

I wrote a simple microbenchmark that does a lot of open() system calls
to create positive or negative dentries. I was not seeing any noticeable
performance difference as long as not too many negative dentries were
created.

Please enlighten me on how kind of performance benchmark that you would
like me to run.

Thanks,
Longman
