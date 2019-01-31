Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668F0C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 21:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FA4120B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 21:00:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FA4120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BFD38E0002; Thu, 31 Jan 2019 16:00:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66F408E0001; Thu, 31 Jan 2019 16:00:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537488E0002; Thu, 31 Jan 2019 16:00:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CAA18E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 16:00:18 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id v3so3713994itf.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:00:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=JfNs1IQFObQr5xrMxDuHg/ScesPqenchZ1UhCm3cKoQ=;
        b=ldXCNp8j7tUy8IxNUV21Jp2MB/ndPnsfAFpdpuTZtsnm0RvD2GD9JkipfFgvJ2KQm9
         ZppG42c/myzO39llppIe9T8yJQJBdczE9m6G/gxFfxRt52hKSnGnq3UKpEj+pcM7bylA
         p3IJAhB9C9D33h/uZDIyUzWQO7jp5zLOwAyGzK03pjEAYyqJvGzz8gOZ2t+XwUiKhpkj
         AKGl1X65d8CWfLm8kuzsznVwqUB6ynHm4lZj7xNzuk8MVVgObxSwZgwihXgnheR4YvAJ
         mHFqwHUQwNz+U+Mkp9IHQIfYdv11zRQQerOfbGIc1BNQTmQtIlNKld0/TF2WJxdU1JoB
         QA9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukdonyBRHx+YjSkHxv474Demkiw+XHc2BuIg8Ca2Bhea/JtPddmG
	iz0OCnLXf8GcX26CJ6k831zJyyhSdujHWpSeXTxjiS0I5iRQHsBkBS2J+7cbjCASWLFZejvb66k
	d7asZ4Afmld1TCbUz9D1757RQPDrtf+l99suUCjc19O7Ffowcso5Ff5X2fdYnh/XXgw==
X-Received: by 2002:a6b:da10:: with SMTP id x16mr20966419iob.101.1548968417968;
        Thu, 31 Jan 2019 13:00:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5YippeymhPFRC34AROWot8B1oo1oqDp9X4JL5Hbqk/m5qQ/3b4r1x6Cqakrpc0IcwaG7nG
X-Received: by 2002:a6b:da10:: with SMTP id x16mr20966397iob.101.1548968417150;
        Thu, 31 Jan 2019 13:00:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548968417; cv=none;
        d=google.com; s=arc-20160816;
        b=Hx1Sl05+u/lHqWUECav/PbWpVrCd4hCufM7Fb2DajoQts5ELXeqfQPZx9gtkeKP7Rn
         m5aFboS1KqOFdWT+rAjMcrDKk0ln+kMxc+pqblr1+eWldJOz477CESxFinnZU0O4e49X
         Etu6rKkJCfWLI8CbnRmIKTZWLtYQY6xgpeVvkP807+yFyG3ozNSlvl0hSOnouJDnTccs
         dt1noA9C+rcJzt/N/k7uFjKxfKLWaMXS9De3OcoJZ1iKwk8X/BxDW0LMy0CKUk3FYBB1
         F1ebh1ixBc74Fd0unXhzme2B5U48ohPa22dwSFn1EBPvFd/+8SaDLpUosZmiVHVd3iNX
         OY7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=JfNs1IQFObQr5xrMxDuHg/ScesPqenchZ1UhCm3cKoQ=;
        b=yLwd7ubYy8mNHHp9lRtimkOUzIknDk3wbVlLRodekfbgkHLU7ektVL55QUhveAoSSd
         tSiz1scyhd9SbPLOz7Z8+hYfdJcR++O97t0HLbYyDf1OcfNqWUDIkkzuMfGbCMgqx2Qg
         DgkGaP+yl0BMFbTpHLXcpTWvYuZQZG/Wh8as2JM3sicboQeDfwizUYlIviX1O1DCWb5x
         ORnluwFW3gdXGZpP756xVEXN8HuweS7D1jRrwPnW9KSjMQKyv8YR6p8lOyVP+onKIrEY
         oMc8oqz6/cEkVhQ8j2HP2RxAdnuupXqnR09f3W4PHDEwgjtpyf20BW3/fVeOMlpmtKD9
         iUCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u8si3096730jaa.105.2019.01.31.13.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 13:00:16 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav102.sakura.ne.jp (fsav102.sakura.ne.jp [27.133.134.229])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0VL06kl083929;
	Fri, 1 Feb 2019 06:00:06 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav102.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav102.sakura.ne.jp);
 Fri, 01 Feb 2019 06:00:06 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav102.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0VKxx1L083877
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 1 Feb 2019 06:00:06 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH v2] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
        Yong-Taek Lee <ytk.lee@samsung.com>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
 <20190117155159.GA4087@dhcp22.suse.cz>
 <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
 <20190131071130.GM18811@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5fd73d87-3e4b-f793-1976-b937955663e3@i-love.sakura.ne.jp>
Date: Fri, 1 Feb 2019 05:59:55 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190131071130.GM18811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/01/31 16:11, Michal Hocko wrote:
> On Thu 31-01-19 07:49:35, Tetsuo Handa wrote:
>> This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
>> processes sharing mm have same view of oom_score_adj") and commit
>> 97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
>> close a race and reduce the latency at __set_oom_adj(), and reduces the
>> warning at __oom_kill_process() in order to minimize the latency.
>>
>> Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
>> to unmap the address space") introduced the worst case mentioned in
>> 44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
>> only administrators can trigger the worst case.
>>
>> Since 44a70adec910d692 did not take latency into account, we can "hold RCU
>> for minutes and trigger RCU stall warnings" by calling printk() on many
>> thousands of thread groups. Also, current code becomes a DoS attack vector
>> which will allow "stalling for more than one month in unkillable state"
>> simply printk()ing same messages when many thousands of thread groups
>> tried to iterate __set_oom_adj() on each other.
>>
>> I also noticed that 44a70adec910d692 is racy [1], and trying to fix the
>> race will require a global lock which is too costly for rare events. And
>> Michal Hocko is thinking to change the oom_score_adj implementation to per
>> mm_struct (with shadowed score stored in per task_struct in order to
>> support vfork() => __set_oom_adj() => execve() sequence) so that we don't
>> need the global lock.
>>
>> If the worst case in 44a70adec910d692 happened, it is an administrator's
>> request. Therefore, before changing the oom_score_adj implementation,
>> let's eliminate the DoS attack vector first.
> 
> This is really ridiculous. I have already nacked the previous version
> and provided two ways around. The simplest one is to drop the printk.
> The second one is to move oom_score_adj to the mm struct. Could you
> explain why do you still push for this?

Dropping printk() does not close the race.
You must propose an alternative patch if you dislike this patch.

> 
>> [1] https://lkml.kernel.org/r/20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8
>>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
>> Nacked-by: Michal Hocko <mhocko@suse.com>
>> ---
>>  fs/proc/base.c     | 46 ----------------------------------------------
>>  include/linux/mm.h |  2 --
>>  mm/oom_kill.c      | 10 ++++++----
>>  3 files changed, 6 insertions(+), 52 deletions(-)
>>

