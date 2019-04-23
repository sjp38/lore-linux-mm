Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CBE3C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:32:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56D1720811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:32:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56D1720811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED4DA6B0007; Tue, 23 Apr 2019 05:32:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E85166B0008; Tue, 23 Apr 2019 05:32:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9BB86B000A; Tue, 23 Apr 2019 05:32:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A26B86B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:32:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j12so3155217pgl.14
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:32:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OeltTJznnL+Qbgdl4mblDCbAYRu8rp0XhfBvj6FWeL4=;
        b=Q9KvuXKz/jcfUEbaTXKNHqgVH+rTHdPg/BFFL1WxSPUNqzdM4atimuohHylLbD+g5o
         VypEZFQ5TFqCYIhnKLxtAdcL051W0o4VpDBkyrfeN0KBpPTM8mrbPjWnrCuGUY7i/8Lr
         pcmGTHIiRsucyUZ1rxxezacJ0RKNl2bVa8EGcEgIwsnxlWOAPzwCS+hPhQNpGVpieZ0k
         ItURkO7BfjLXwOvT7Q63laSvwO5F3KFx88hEI5xG63g8/B9SOskCyrPQcd6gun6hAozn
         O2XcJHN9kYUSAEKZJoJjUcNW8syTrGV53mxL698M8lTdviTqHp3dbuj7sF42YB4JhggL
         gtmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXL3Osiw0vUII4r3fA9V0tMvbsTNJh1FJzrMA9MlcuBG0eTmCkU
	X3AC4kAkHLZw57LYUkcwcmHY+K9RpOPVwjrAuRJOGOvgoKOHmHtZofcMHAWWiMgZuqIbRNFaHS4
	d7vBj0yR+f8Y42o9crm3WfRfTSsWUmHuDhOynEHVlMEIOt6E+IeLtEesD5uWLBckXqg==
X-Received: by 2002:a17:902:7e04:: with SMTP id b4mr3009365plm.211.1556011952288;
        Tue, 23 Apr 2019 02:32:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhbWWvD7AVz87mohrBHej+NLskClSgbq/VawzGQGCBw9/0M/sSnjunmYOzPmDq+uAzWr7S
X-Received: by 2002:a17:902:7e04:: with SMTP id b4mr3009295plm.211.1556011951576;
        Tue, 23 Apr 2019 02:32:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556011951; cv=none;
        d=google.com; s=arc-20160816;
        b=AuL6WhAV2GN6uDEkcjI1CRp9RXtw9DHpIj7JbQzYEMU1Nao8JUhjEIFNadgWUyfzHS
         sL95GOU/U/yyyyI9ASOGKQ8buPdQfmA91mhYP9SZAvi3kXnSRmW3LiJi47S9Tqcu6w0j
         YEsWObhfJ7wfIaU7BzRP7JzEzm+XmBLj13Jz+84iIPnOndrUYfJC3OwoynMZS8gMzLu1
         5qsii7TGSnlzfz/JUF80CAZdIXdWw5d+gLnJNUsCYKnyRSYt0gh/MAGdoTth6JFZ3F7p
         V1Wv1L20gJUUsDfklwz/NQjMbI95UZTciAKxUBXAx25qeOANJmzasmmd9wAbPdHAi/fU
         ob0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=OeltTJznnL+Qbgdl4mblDCbAYRu8rp0XhfBvj6FWeL4=;
        b=X6ABu+zIw7Xsyqs3mEATmchDwPSuZcUz1HDuh8VeH0JnKOsPsD1i4arb34bPaDFXzL
         kPZlJ4UfWAArwL7dvUh7kYfbn/jeP+9zZ0SNzNnJqZeEgfuHb8BEvP387FOprlbVYa5I
         Q98qO+OCm6MWF30LNd9bGA7J6GwqIy1lK8WZd/pXQhgh3N9h/WlFUMwDLjxfztf1vYAz
         ydPDh6LtSO6+e2E7+FrNTqssaSg0MGQopVfdlj6VbOdQz7Agt4iFDVPW643GfJxKqUkv
         QSuGoxaOSiEAJ08fWc8VqT4MJT2OgvtrW0h3fYA9vy7aNVULet50L+SuMP20yi8D1C7q
         WFqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id c14si16176192pfn.40.2019.04.23.02.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 02:32:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ1gXzQ_1556011948;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ1gXzQ_1556011948)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 17:32:29 +0800
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
 <20190423084633.GC11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <f1f71150-b3e9-7d15-7a0b-57673a9021d5@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:32:28 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423084633.GC11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/4/23 下午4:46, Peter Zijlstra wrote:
> On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
>> +	 * 0 -- remote faults
>> +	 * 1 -- local faults
>> +	 * 2 -- page migration failure
>> +	 * 3 -- remote page accessing after page migration
>> +	 * 4 -- local page accessing after page migration
> 
>> @@ -2387,6 +2388,11 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
>>  		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
>>  	}
>>
>> +	p->numa_faults_locality[mem_node == numa_node_id() ? 4 : 3] += pages;
>> +
>> +	if (mem_node == NUMA_NO_NODE)
>> +		return;
> 
> I'm confused on the meaning of 3 & 4. It says 'after page migration' but
> 'every' access if after 'a' migration. But even more confusingly, you
> even account it if we know the page has never been migrated.
> 
> So what are you really counting
Here is try to get the times of a task accessing the local or remote pages,
and on no migration cases we still account since it's also one time of accessing,
remotely or locally.

'after page migration' means this accounting need to understand the real page
position after PF, what ever migration failure or succeed, whatever page move to
local/remote or untouched, we want to know the times a task accessed the page
locally or remotely, on numa balancing period.

Regards,
Michael Wang

> 

