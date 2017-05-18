Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABEE831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:56:43 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v195so17268918qka.1
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:56:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z51si5865508qtz.214.2017.05.18.08.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 08:56:42 -0700 (PDT)
Subject: Re: [RFC PATCH v2 09/17] cgroup: Keep accurate count of tasks in each
 css_set
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-10-git-send-email-longman@redhat.com>
 <20170517214034.GF942@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <b0a5ea12-317f-70a3-2efe-e0b7f7673e3e@redhat.com>
Date: Thu, 18 May 2017 11:56:38 -0400
MIME-Version: 1.0
In-Reply-To: <20170517214034.GF942@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/17/2017 05:40 PM, Tejun Heo wrote:
> Hello,
>
> On Mon, May 15, 2017 at 09:34:08AM -0400, Waiman Long wrote:
>> The reference count in the css_set data structure was used as a
>> proxy of the number of tasks attached to that css_set. However, that
>> count is actually not an accurate measure especially with thread mode
>> support. So a new variable task_count is added to the css_set to keep
>> track of the actual task count. This new variable is protected by
>> the css_set_lock. Functions that require the actual task count are
>> updated to use the new variable.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> Looks good.  We probably should replace css_set_populated() to use
> this too.
>
> Thanks.
>
Yes, you are right. css_set_populated() can be replaced with a check on
the task_count.

Regards,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
