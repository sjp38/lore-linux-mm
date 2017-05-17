Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 841096B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 16:24:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f96so8475275qki.14
        for <linux-mm@kvack.org>; Wed, 17 May 2017 13:24:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b67si3175274qkd.110.2017.05.17.13.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 13:24:36 -0700 (PDT)
Subject: Re: [RFC PATCH v2 07/17] cgroup: Prevent kill_css() from being called
 more than once
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-8-git-send-email-longman@redhat.com>
 <20170517192357.GC942@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <c541638f-b302-8c96-0dcd-f4b758a4a81f@redhat.com>
Date: Wed, 17 May 2017 16:24:32 -0400
MIME-Version: 1.0
In-Reply-To: <20170517192357.GC942@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/17/2017 03:23 PM, Tejun Heo wrote:
> Hello,
>
> On Mon, May 15, 2017 at 09:34:06AM -0400, Waiman Long wrote:
>> The kill_css() function may be called more than once under the condition
>> that the css was killed but not physically removed yet followed by the
>> removal of the cgroup that is hosting the css. This patch prevents any
>> harmm from being done when that happens.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> So, this is a bug fix which isn't really related to this patchset.
> I'm applying it to cgroup/for-4.12-fixes w/ stable cc'd.
>
> Thanks.
>
Actually, this bug can be easily triggered with the resource domain
patch later in the series. I guess it can also happen in the current
code base, but I don't have a test that can reproduce it.

Regards,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
