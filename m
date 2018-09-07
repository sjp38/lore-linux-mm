Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0FC46B7E8D
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 09:30:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m21-v6so16673814oic.7
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 06:30:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d84-v6si5438099oia.219.2018.09.07.06.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 06:30:21 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <20180906113553.GR14951@dhcp22.suse.cz>
 <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
 <20180906120508.GT14951@dhcp22.suse.cz>
 <37b763c1-b83e-1632-3187-55fb360a914e@i-love.sakura.ne.jp>
 <20180906135615.GA14951@dhcp22.suse.cz>
 <8dd6bc67-3f35-fdc6-a86a-cf8426608c75@i-love.sakura.ne.jp>
 <20180906141632.GB14951@dhcp22.suse.cz>
 <55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp>
 <20180907111038.GH19621@dhcp22.suse.cz>
 <4e1bcda7-ab40-3a79-f566-454e1f24c0ff@i-love.sakura.ne.jp>
 <20180907115132.GJ19621@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9d838223-5a57-e291-eca3-8a4b04a78b65@i-love.sakura.ne.jp>
Date: Fri, 7 Sep 2018 22:30:06 +0900
MIME-Version: 1.0
In-Reply-To: <20180907115132.GJ19621@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/09/07 20:51, Michal Hocko wrote:
> On Fri 07-09-18 20:36:31, Tetsuo Handa wrote:
>> On 2018/09/07 20:10, Michal Hocko wrote:
>>>> I can't waste my time in what you think the long term solution. Please
>>>> don't refuse/ignore my (or David's) patches without your counter
>>>> patches.
>>>
>>> If you do not care about long term sanity of the code and if you do not
>>> care about a larger picture then I am not interested in any patches from
>>> you. MM code is far from trivial and no playground. This attitude of
>>> yours is just dangerous.
>>>
>>
>> Then, please explain how we guarantee that enough CPU resource is spent
>> between "exit_mmap() set MMF_OOM_SKIP" and "the OOM killer finds MMF_OOM_SKIP
>> was already set" so that last second allocation with high watermark can't fail
>> when 50% of available memory was already reclaimed.
> 
> There is no guarantee. Full stop! This is an inherently racy land. We
> can strive to work reasonably well but this will never be perfect.

That is enough explanation that we have no choice but mitigate it using
heuristics. No feedback based approach is possible. My or David's patch
has been justified. Thank you!
