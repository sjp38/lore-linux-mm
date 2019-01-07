Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 687458E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:21:01 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id a19so164775otq.1
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:21:01 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y66si32771964ota.203.2019.01.07.06.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 06:20:55 -0800 (PST)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
 <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
 <20190107133720.GH31793@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2e35e48e-ac7f-4d67-2937-3af0e3064bd1@i-love.sakura.ne.jp>
Date: Mon, 7 Jan 2019 23:20:47 +0900
MIME-Version: 1.0
In-Reply-To: <20190107133720.GH31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 2019/01/07 22:37, Michal Hocko wrote:
> On Mon 07-01-19 22:07:43, Tetsuo Handa wrote:
>> On 2019/01/07 20:41, Michal Hocko wrote:
>>> On Sun 06-01-19 15:02:24, Tetsuo Handa wrote:
>>>> Michal and Johannes, can we please stop this stupid behavior now?
>>>
>>> I have proposed a patch with a much more limited scope which is still
>>> waiting for feedback. I haven't heard it wouldn't be working so far.
>>>
>>
>> You mean
>>
>>   mutex_lock_killable would take care of exiting task already. I would
>>   then still prefer to check for mark_oom_victim because that is not racy
>>   with the exit path clearing signals. I can update my patch to use
>>   _killable lock variant if we are really going with the memcg specific
>>   fix.
>>
>> ? No response for two months.
> 
> I mean http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
> which has died in nit picking. I am not very interested to go back there
> and spend a lot of time with it again. If you do not respect my opinion
> as the maintainer of this code then find somebody else to push it
> through.
> 

OK, you haven't proposed an updated patch. Since nobody can test
not-yet-proposed patch, you haven't heard it wouldn't be working so far.
