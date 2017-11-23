Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA7E6B026D
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:43:30 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id r55so9883716otc.23
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:43:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p1si8119305otp.471.2017.11.23.02.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 02:43:29 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
References: <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
 <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
 <20171122203907.GI4094@dastard>
 <201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
 <2178e42e-9600-4f9a-4b91-22d2ba6f98c0@redhat.com>
 <201711231856.CFH69777.FtOSJFMQHLOVFO@I-love.SAKURA.ne.jp>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <83429cb3-4962-4a16-793e-42483a843c75@redhat.com>
Date: Thu, 23 Nov 2017 11:43:21 +0100
MIME-Version: 1.0
In-Reply-To: <201711231856.CFH69777.FtOSJFMQHLOVFO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, mhocko@kernel.org, akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On 23/11/2017 10:56, Tetsuo Handa wrote:
> Paolo Bonzini wrote:
>> On 23/11/2017 07:34, Tetsuo Handa wrote:
>>>> Just fix the numa aware shrinkers, as they are the only ones that
>>>> will have this problem. There are only 6 of them, and only the 3
>>>> that existed at the time that register_shrinker() was changed to
>>>> return an error fail to check for an error. i.e. the superblock
>>>> shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.
>>>
>>> You are assuming the "too small to fail" memory-allocation rule
>>> by ignoring that this problem is caused by fault injection.
>>
>> Fault injection should also obey the too small to fail rule, at least by
>> default.
> 
> Pardon? Most allocation requests in the kernel are <= 32KB.
> Such change makes fault injection useless. ;-)

But if these calls are "too small to fail", you are injecting a fault on
something that cannot fail anyway.  Unless you're aiming at removing
"too small to fail", then I understand.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
