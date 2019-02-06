Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57E5DC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 14:58:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1793D20844
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 14:58:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1793D20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 936088E00C6; Wed,  6 Feb 2019 09:58:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E4078E00C1; Wed,  6 Feb 2019 09:58:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 784268E00C6; Wed,  6 Feb 2019 09:58:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F88C8E00C1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 09:58:11 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so5078978plb.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 06:58:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZQ0xmV5D3s7v6KuybbYb7l0uNRCKSsdtVrvJCPe8I5Q=;
        b=YTpI3cu41XOPnTYFfmfpxAgCtleWbdDMpCYBlQThyJqtEoNKuKNvEXJfwNXuT1Cpbo
         4q4Y26u4zVnkR4JoiRSOHUnkg/9tg1QL7KhONMuAbVyG+g0pj6ppNVyYwz9ZAXm5XN7b
         fXV8KWAKZexfggvThARYCGfA4A44ILaPbKg9+r9hCz+/mp04Q/OulBuPxjDcBBuTo0FC
         /Iy70eGTqxqDLKQHwQ1Nf5AdcW81W9vdlZTa/AalWTudsFKnsgzhtBMN1zbYDDoxyai4
         7hDHWjycjRuwS/j/78qsymK/hHPj2lorfbQaU3LLLwt7V35qgH9c2Z9FbiLMCud7gWCT
         RARQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAubp0JtzGX36Wy+bReJT1kY/Yf0AsohjnoL7i4dC4Th9bLs/L78Y
	wbTF5B6AR98Kf2sYtrOdGykv3SIziGeJjlHkbsUQaUs8ijmS6MFs3Dz1yHyiQMsUn+e+aLrp3px
	RftNRuZoobBXSgVPd9Au3lQYMa+zVDQqe4xJTeKh9NZ3Q+JJUGNe5p43DlooCPIIo+A==
X-Received: by 2002:a63:dc54:: with SMTP id f20mr10044964pgj.410.1549465090841;
        Wed, 06 Feb 2019 06:58:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKZAZIz2MwKXJDGwS83P2ByOLPZf+c5Sj2FNRB599e8Mp1wAQP7UuzM+aE7YsoBmPIt/3o
X-Received: by 2002:a63:dc54:: with SMTP id f20mr10044918pgj.410.1549465090092;
        Wed, 06 Feb 2019 06:58:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549465090; cv=none;
        d=google.com; s=arc-20160816;
        b=wicYLAL9UR8J6UZNXHjmwReVHgBFtEdBcecLXKrdz6skRcE38RWviUQDPupxaVRSDL
         o6uUz+BZ5p49ePKxwrpwYD9oZuzXv9lf9bkJtav//h4bptZ5PbIuxMCY9/W4MvJLBsN4
         qLNZOSxxRbyYLMozEX35luHU2KxSD2efzuqBkyzZStPeQdXyGRnJbIIZIohjmyB1RDsI
         Ks1LqKau+wjK2DPfSBloV97Sor/rKyAHMIhWkVQRJf1Efa73oN3rGdRj1xZ/4qvM2s0O
         KTciyz00hxVFiQt4dGkVX682dQgmr6K+zkU/8DPUzLkNqq0BmCiMxZp0RgeJXEDaOe+z
         t2sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZQ0xmV5D3s7v6KuybbYb7l0uNRCKSsdtVrvJCPe8I5Q=;
        b=HXabCiYL/hV2yq6FC5ZoUn/MFTbwNx6PFytwpPbKkKqoGd72slRc6OUzSJ3teSeIz3
         uQCWFp8BYLqFVx50XsG1Mw/XSketkX6o6HaanB5z4QV5CWjqk5KRSdFbrSeTXdssH5dg
         RBp13VparDRiRq+GZOTgLjxL+DyPu3prPUyQ3MtMEP/ko3tiAE9knP8hzz3YuJQSy730
         5oMEv9GadOS2GeMKpH42zZBdyyjYPpgvCwCg3Dq9L+ko9Eg1ZN5CqMPl9ri63G+YZt8v
         4cZ+mehHBQmAKg5ki4kx7mmMqQRQ3iETXBwP9gCpwfhRLF+nE4KjUCN0vAsMGxbyGQdP
         3bhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 31si4250437plj.244.2019.02.06.06.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 06:58:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav109.sakura.ne.jp (fsav109.sakura.ne.jp [27.133.134.236])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x16Evkl3045080;
	Wed, 6 Feb 2019 23:57:46 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav109.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav109.sakura.ne.jp);
 Wed, 06 Feb 2019 23:57:46 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav109.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x16EviNl045047
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 6 Feb 2019 23:57:45 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: linux-next: tracebacks in workqueue.c/__flush_work()
To: Guenter Roeck <linux@roeck-us.net>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>
References: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
 <87munc306z.fsf@rustcorp.com.au>
 <201902060631.x166V9J8014750@www262.sakura.ne.jp>
 <20190206143625.GA25998@roeck-us.net>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <e4dd7464-a787-c54f-24f9-9caaeb759cfc@i-love.sakura.ne.jp>
Date: Wed, 6 Feb 2019 23:57:45 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190206143625.GA25998@roeck-us.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/06 23:36, Guenter Roeck wrote:
> On Wed, Feb 06, 2019 at 03:31:09PM +0900, Tetsuo Handa wrote:
>> (Adding linux-arch ML.)
>>
>> Rusty Russell wrote:
>>> Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> writes:
>>>> (Adding Chris Metcalf and Rusty Russell.)
>>>>
>>>> If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
>>>> evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
>>>> previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
>>>> commits listed below.
>>>>
>>>>   Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
>>>>   expects that has_work is evaluated by for_each_cpu().
>>>>
>>>>   Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
>>>>   assumes that for_each_cpu() does not need to evaluate has_work.
>>>>
>>>>   Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
>>>>   expects that has_work is evaluated by for_each_cpu().
>>>>
>>>> What should we do? Do we explicitly evaluate has_work if NR_CPUS == 1 ?
>>>
>>> No, fix the API to be least-surprise.  Fix 2d3854a37e8b767a too.
>>>
>>> Doing anything else would be horrible, IMHO.
>>>
>>
>> Fixing 2d3854a37e8b767a might involve subtle changes. If we do
>>
> 
> Why not fix the macros ?
> 
> #define for_each_cpu(cpu, mask)                 \
>         for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
> 
> does not really make sense since it does not evaluate mask.
> 
> #define for_each_cpu(cpu, mask)                 \
>         for ((cpu) = 0; (cpu) < 1 && cpumask_test_cpu((cpu), (mask)); (cpu)++)
> 
> or something similar might do it.

Fixing macros is fine, The problem is that "mask" becomes evaluated
which might be currently undefined or unassigned if CONFIG_SMP=n.
Evaluating "mask" generates expected behavior for lru_add_drain_all()
case. But there might be cases where evaluating "mask" generate
unexpected behavior/results.

