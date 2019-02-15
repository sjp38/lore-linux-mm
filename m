Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3264C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:27:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66D12192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:27:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66D12192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46EDE8E0002; Fri, 15 Feb 2019 09:27:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41E318E0001; Fri, 15 Feb 2019 09:27:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35D008E0002; Fri, 15 Feb 2019 09:27:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6E58E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:27:49 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id n124so15934792itb.7
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:27:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=G8sLvgVTsx2D5zU1ivXpDSWlx6mDSsT3r677meWDaPU=;
        b=bmzT0tGRTdvHtlp9DoNSoR8LIooXmYs4xTB8XI7Q7dPlVC9KKakuZuBHfy/iKuKk/s
         KhbFMe3G6okGe1QbwVwQRenFScxjUGUMsbhU52zr6UOPiPWEPxM2fqogSIUz4ODKYmqe
         hjMGqIF0w+FAqvB6zk028himWVlYV4da8oEMEk+Me4O53MB7QxeDx1PQrfMvoMgXXYtk
         ZLk3Zk2mnVzXpJreBVHY0l/qEGd1o4eg7XHe7GyxxysTL0dspAf640PESP/VjOAugaKb
         z/EE4wVrfbgloIjuYA9BE+ltL916B1YlYzQjdwB7ocyMgx8aBgtdSCf3L2DMkLw9/aZX
         6bIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZYVF7/rc3678wyAd0jIjkrRVnk40aB55E3r1d84p8CxEmYDyVS
	0woMZb3IQ1tJV0kA96K7/CbiXl3xI5MMd7irNjHSeTMHRYTuLRZhHQqw/DBzDSJE6ReYkD4Y3t9
	CBILSaBio/ND/N9MhiHj8rNBD4Qjh65ricR/xHz1Y5gs7tV5sRYhAPOu7ID68Qor4wQ==
X-Received: by 2002:a5d:8049:: with SMTP id b9mr4956157ior.302.1550240868861;
        Fri, 15 Feb 2019 06:27:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBzeo5HsJiS4Eg53vSKTSOv+E8XF8/rNHj3HwzI0Pk0ktfLUTJv7D7knsCKBHSGxAeYLTZ
X-Received: by 2002:a5d:8049:: with SMTP id b9mr4956116ior.302.1550240868105;
        Fri, 15 Feb 2019 06:27:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550240868; cv=none;
        d=google.com; s=arc-20160816;
        b=KCJj+1kDjoScWaOhe4DJmW9VHpKgerdBAceuUeqggUu9xrE1DgGmPjrMWg5frNT5vK
         jDBnMCLCMHMgcXnTje44mg1ITHk19MHBpnqpQ1vlVGLFN6z8HblOuNrXQY4J0XnAO4Rn
         14HK9VEA+EGfouUq/jxOka/DNGKzhbYq2LwHd2dNcUIvqiH9Uc9J39TfyxhSjFUdvfmq
         W44FHtJrAt8gX43h/T9FS8QnHK9PablfWxJOnycdyKooQ+uNgo0y06Hp64Hr//Uznhr9
         t2+5iJDpOlQtIYfrQiC3B5nFAHBtDICtJh8aFlAMD2AJHMVtpxEQndj8ZXVNrYUnEiRu
         77RQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=G8sLvgVTsx2D5zU1ivXpDSWlx6mDSsT3r677meWDaPU=;
        b=aQOcar7f4GWi+kop2D1DnFlD37yLJ6R/iN0z0dGcfSUG89nrF0ixhSJaGJmxWc6pjW
         BxhWkA6lJk+pLmW1k4pphzLzaJDfh7bieM00qXT9a6GwakzLqXkwUBdOpa/USLJ3BWnO
         VEsShCno1pYLbnS3QMdTE8okvJKObmYr8fLhTezhbLwSPzj8ILfnWSctpNczyG+H/AIn
         oXUoDYfez/0uSR7/OC08GKK/9iO/LSGcevKwZQb8LHMP2/PClyK8LgEonJcMX7fdiZ7O
         kqZ8uRiX+FEkX9sdCNX+gJhfIcAEvkuN03Zoninkm0fZpD7rqLAtoG6N7DJMB2h5Q3tG
         km8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x72si97901itb.65.2019.02.15.06.27.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 06:27:47 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1FERfJw095720;
	Fri, 15 Feb 2019 23:27:41 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Fri, 15 Feb 2019 23:27:41 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1FERRt0095514
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 15 Feb 2019 23:27:41 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [linux-next-20190214] Free pages statistics is broken.
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
References: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
 <20190215130147.GZ4525@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1189d67e-3672-5364-af89-501cad94a6ac@i-love.sakura.ne.jp>
Date: Fri, 15 Feb 2019 23:27:25 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190215130147.GZ4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/15 22:01, Michal Hocko wrote:
> On Fri 15-02-19 11:27:10, Tetsuo Handa wrote:
>> I noticed that amount of free memory reported by DMA: / DMA32: / Normal: fields are
>> increasing over time. Since 5.0-rc6 is working correctly, some change in linux-next
>> is causing this problem.
> 
> Just a shot into the dark. Could you try to disable the page allocator
> randomization (page_alloc.shuffle kernel command line parameter)? Not
> that I see any bug there but it is a recent change in the page allocator
> I am aware of and it might have some anticipated side effects.
> 

I tried CONFIG_SHUFFLE_PAGE_ALLOCATOR=n but problem still exists.

[   45.788185][    C3] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15872kB
[   45.793869][    C3] Node 0 DMA32: 2017*4kB (M) 1007*8kB () 511*16kB (UM) 257*32kB (UM) 129*64kB (UM) 62*128kB () 33*256kB (UM) 15*512kB (U) 9*1024kB (UM) 186*2048kB (M) 481*4096kB (M) = 2425164kB
[   45.800355][    C3] Node 0 Normal: 71712*4kB () 32360*8kB () 16640*16kB (UME) 10536*32kB (UE) 5199*64kB (UME) 2551*128kB (M) 1232*256kB (UM) 604*512kB () 300*1024kB (UM) 233*2048kB (E) 4*4096kB (M) = 3233792kB

[  212.578797][ T9783] Node 0 DMA: 298*4kB (UM) 151*8kB (UM) 76*16kB (U) 41*32kB (UM) 21*64kB (UM) 11*128kB (U) 8*256kB (UM) 5*512kB (M) 3*1024kB (U) 0*2048kB 3*4096kB (M) = 27648kB
[  212.585534][ T9783] Node 0 DMA32: 18100*4kB () 8704*8kB (UM) 3984*16kB (M) 1704*32kB (M) 673*64kB (M) 261*128kB (M) 139*256kB (M) 48*512kB (UM) 23*1024kB (UM) 1308*2048kB (M) 10*4096kB (UM) = 3140240kB
[  212.593410][ T9783] Node 0 Normal: 285472*4kB (H) 105638*8kB (UEH) 43419*16kB (UEH) 19474*32kB (UEH) 7986*64kB (H) 3628*128kB () 1661*256kB () 753*512kB () 349*1024kB () 316*2048kB () 0*4096kB = 6095648kB

[  230.654713][ T9550] Node 0 DMA: 298*4kB (UM) 151*8kB (UM) 76*16kB (U) 41*32kB (UM) 21*64kB (UM) 11*128kB (U) 8*256kB (UM) 5*512kB (M) 3*1024kB (U) 0*2048kB 3*4096kB (M) = 27648kB
[  230.661248][ T9550] Node 0 DMA32: 29452*4kB () 14391*8kB () 6814*16kB () 3109*32kB (M) 1365*64kB (M) 491*128kB (M) 263*256kB (M) 150*512kB (M) 125*1024kB (M) 1309*2048kB (UM) 10*4096kB (UM) = 3585576kB
[  230.669879][ T9550] Node 0 Normal: 367054*4kB (UMEH) 123969*8kB (UMEH) 48498*16kB (UMEH) 20325*32kB (UMEH) 8069*64kB (UMH) 3640*128kB (H) 1662*256kB (H) 753*512kB () 350*1024kB (H) 316*2048kB () 0*4096kB = 6685248kB

