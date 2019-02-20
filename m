Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BBD9C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 10:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA73020C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 10:00:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA73020C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 642F68E0004; Wed, 20 Feb 2019 05:00:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F1498E0002; Wed, 20 Feb 2019 05:00:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B8B28E0004; Wed, 20 Feb 2019 05:00:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09EA58E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:00:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 11so13112928pgd.19
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 02:00:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3DcssLqZvpgTU7uImXqBrwY6Uy9wX1ccjQtb2KtXQQM=;
        b=lgrXY6r2nF9ADA1Fpe76xSNsZEpk6BTBE+/5erEnOY9FqK2GhLLTfiwx6IYswUb4sH
         Ry2K+/QYRgNqLWm1oK2c8FQOjlk4yzyoX5nWnpM+otIus5gydIut22KnuJ+DlyPBfxpC
         goxBWX1g4yIYbu3U5IYieNpoma34zm8hqNd/uiw+jD8t71CvhMsMHnhuwYrx0qWFY0v7
         pOUsutIJI3/4uxY3iq7PbuaTi3GdFIi6s80p7j+u5/4hC0rf1AcCGsGMbkBVNcMGQaui
         Bi2L7ZqkNOcpaMZfEqOR4a4GZOH5YhWHxe8tSxhZbJKGc2qs1Qa3Gz0nz3KQfWbZCXys
         2tQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZJc4Y7DlM/MfPZ9oFg9bQpQOIMB3zgyVLf/0MXT7eDLp1rtEnv
	FSW7uu5hUbERzdWm+ZDVbXE4FqjYbf4pdOVhLktfG+4iRUualSO6jsplZr5zdo0Xd/SyBGD9A+B
	s1PBi/GgnvcK8gMMzkItHrZtqvJk5iknS6zwwzEd4iKwfoPle/iAsj3X7qxtMk8ZGfA==
X-Received: by 2002:a17:902:2468:: with SMTP id m37mr35953701plg.314.1550656829418;
        Wed, 20 Feb 2019 02:00:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbD/H8rZeadaUucW1aLdLPpa9kpFUios1MX1/luJEh25x1KcUPm2xZs+7ylvE92CKA+0mGG
X-Received: by 2002:a17:902:2468:: with SMTP id m37mr35953642plg.314.1550656828660;
        Wed, 20 Feb 2019 02:00:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550656828; cv=none;
        d=google.com; s=arc-20160816;
        b=FVzFoU6fHLUT1zuU9acDgvQFmlKJuCsgSVswv0xgT/JSpLiRpRdjzcSUpmfLToPni/
         dzudqD9j6gg5dszWutXECxcABEM1m1hcczODaHoHE5f2nCvaztxZoAfN8FSojhhUxmRH
         v8sD+XzDd6h8tzQzKcmBWIsOOxD59gnxGo+vm+MYO1mCsyjXNrOe//gFMZdO+jZV4oqa
         DQJlA5k7ffHXN+8f6RWFIEqY6Zx3SY5LLUH4zo8sTpf3neiYyd7hrRBiACTtWEGDTPkQ
         UYkIrQf2xZD6qSOe7orQmexD5+Q+n5UEEgJT6F9twNJKlmZ7bJHLhJ0Ft9sREnnXrXc0
         hW7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3DcssLqZvpgTU7uImXqBrwY6Uy9wX1ccjQtb2KtXQQM=;
        b=XTOPlIPf2JdgoLJxIkLMgbPTWxRxeXsX5GeqLagINThYNM0dYXfc7sye4fimyL+I6G
         HRM2/VC5s1iN/oU7sUWcDdDodyo14H4kVJ0EB2474mzFDkR9f+c52DxgS0D+zkoqi50c
         l3EPNWs2ZkRMjUP0jzdaL3+XDb3r+0SICjUIykrHRvuC+AtDn82+Wpnx0dDknCsofznB
         tDUVZFuLHHtfiXOGRQVYPy4a8wFIJL75LfyE3SGJZcWjLIzKicLpPIf5zrjFaCJ5h+2H
         yUBFqN5i7T2GZNwY9tGDkTiJsLq5vSH3JUjQiA0kcGc49UNl/yOL9+EnfDqPAv5frGqL
         19Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j2si13663370plk.220.2019.02.20.02.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 02:00:28 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav108.sakura.ne.jp (fsav108.sakura.ne.jp [27.133.134.235])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1KA0NXt077981;
	Wed, 20 Feb 2019 19:00:23 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav108.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp);
 Wed, 20 Feb 2019 19:00:23 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1KA0HD8077948
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 20 Feb 2019 19:00:23 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
To: "Bujnak, Stepan" <stepan@pex.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
        Jonathan Corbet <corbet@lwn.net>, mcgrof@kernel.org,
        hannes@cmpxchg.org
References: <20190220032245.2413-1-stepan@pex.com>
 <20190220064939.GT4525@dhcp22.suse.cz>
 <CAFZe2nQW3mUGgSVndzmPirz7BkVUCEyjt=hgxqFn=bntrCsC8A@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <0dfa8928-4baa-124f-2dd5-e45af28427e8@I-love.SAKURA.ne.jp>
Date: Wed, 20 Feb 2019 19:00:19 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAFZe2nQW3mUGgSVndzmPirz7BkVUCEyjt=hgxqFn=bntrCsC8A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/20 17:37, Bujnak, Stepan wrote:
>>> @@ -404,9 +406,18 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>>>       pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>>>       rcu_read_lock();
>>>       for_each_process(p) {
>>> +             char *name, *cmd = NULL;
>>> +
>>>               if (oom_unkillable_task(p, memcg, nodemask))
>>>                       continue;
>>>
>>> +             /*
>>> +              * This needs to be done before calling find_lock_task_mm()
>>> +              * since both grab a task lock which would result in deadlock.
>>> +              */
>>> +             if (sysctl_oom_dump_task_cmdline)
>>> +                     cmd = kstrdup_quotable_cmdline(p, GFP_KERNEL);
>>> +
>>>               task = find_lock_task_mm(p);
>>>               if (!task) {
>>>                       /*
>> You are trying to allocate from the OOM context. That is a big no no.
>> Not to mention that this is deadlock prone because get_cmdline needs
>> mmap_sem and the allocating context migh hold the lock already. So the
>> patch is simply wrong.
>>
> 
> Thanks for the notes. I understand how allocating from OOM context
> is a problem. However I still believe that this would be helpful
> for debugging OOM kills since task->comm is often not descriptive
> enough. Would it help if instead of calling kstrdup_quotable_cmdline()
> which allocates the buffer on heap I called get_cmdline() directly
> passing it stack-allocated buffer of certain size e.g. 256?

You made triple errors. First is that doing GFP_KERNEL allocation inside
rcu_read_lock()/rcu_read_unlock() is not permitted. Second is that doing
GFP_KERNEL allocation with oom_lock held is not permitted. Third is that
somebody might be already holding p->mm->mmap_sem for write when
get_cmdline() tries to hold it for read. That is, your patch can't work
(even if you update your patch to use static buffer).

