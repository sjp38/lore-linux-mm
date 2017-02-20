Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA3A76B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 00:22:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 65so156516717pgi.7
        for <linux-mm@kvack.org>; Sun, 19 Feb 2017 21:22:34 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 205si17460348pgc.109.2017.02.19.21.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Feb 2017 21:22:33 -0800 (PST)
Subject: Re: Query on per app memory cgroup
References: <b7ee0ad3-a580-b38a-1e90-035c77b181ea@codeaurora.org>
 <b11e01d9-7f67-5c91-c7da-e5a95996c0ec@codeaurora.org>
 <CAA_GA1eMYOPwm8iqn6QLVRvn7vFi3Ae6CbpkLU7iO=J+jE=Yiw@mail.gmail.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <ed013bac-e3b9-feb1-c7ce-26c982bf04b7@codeaurora.org>
Date: Mon, 20 Feb 2017 10:52:27 +0530
MIME-Version: 1.0
In-Reply-To: <CAA_GA1eMYOPwm8iqn6QLVRvn7vFi3Ae6CbpkLU7iO=J+jE=Yiw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, shashim@codeaurora.org



On 2/17/2017 6:47 PM, Bob Liu wrote:
> On Thu, Feb 9, 2017 at 7:16 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
>> Hi,
>>
>> We were trying to implement the per app memory cgroup that Johannes
>> suggested (https://lkml.org/lkml/2014/12/19/358) and later discussed during
>> Minchan's proposal of per process reclaim
>> (https://lkml.org/lkml/2016/6/13/570). The test was done on Android target
>> with 2GB of RAM and cgroupv1. The first test done was to just create per
>> app cgroups without modifying any cgroup controls. 2 kinds of tests were
>> done which gives similar kind of observation. One was to just open
>> applications in sequence and repeat this N times (20 apps, so around 20
>> memcgs max at a time). Another test was to create around 20 cgroups and
>> perform a make (not kernel, another less heavy source) in each of them.
>>
>> It is observed that because of the creation of memcgs per app, the per
>> memcg LRU size is so low and results in kswapd priority drop. This results
> How did you confirm that? Traced the get_scan_count() function?
> You may hack this function for more verification.
This was confirmed by adding some VM event counters in get_scan_count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
