Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C5F3C4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 02:33:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCBA420578
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 02:33:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCBA420578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 720406B032D; Wed, 18 Sep 2019 22:33:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D0D86B032F; Wed, 18 Sep 2019 22:33:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E7026B0330; Wed, 18 Sep 2019 22:33:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0083.hostedemail.com [216.40.44.83])
	by kanga.kvack.org (Postfix) with ESMTP id 3E17E6B032D
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 22:33:21 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D2FF9824376C
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:33:20 +0000 (UTC)
X-FDA: 75950098560.20.crime15_3a25340cb3d26
X-HE-Tag: crime15_3a25340cb3d26
X-Filterd-Recvd-Size: 4517
Received: from wangsu.com (mail.wangsu.com [123.103.51.198])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:33:19 +0000 (UTC)
Received: from localhost.localdomain (unknown [218.85.123.226])
	by app1 (Coremail) with SMTP id xjNnewBnBOjm6IJdKGYBAA--.30S2;
	Thu, 19 Sep 2019 10:33:11 +0800 (CST)
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling memory
 reclaim IO congestion_wait length
To: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: corbet@lwn.net, mcgrof@kernel.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, keescook@chromium.org,
 mchehab+samsung@kernel.org, mgorman@techsingularity.net, vbabka@suse.cz,
 ktkhai@virtuozzo.com, hannes@cmpxchg.org
References: <20190917115824.16990-1-linf@wangsu.com>
 <20190917120646.GT29434@bombadil.infradead.org>
 <20190918123342.GF12770@dhcp22.suse.cz>
From: Lin Feng <linf@wangsu.com>
Message-ID: <6ae57d3e-a3f4-a3db-5654-4ec6001941a9@wangsu.com>
Date: Thu, 19 Sep 2019 10:33:10 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190918123342.GF12770@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CM-TRANSID:xjNnewBnBOjm6IJdKGYBAA--.30S2
X-Coremail-Antispam: 1UD129KBjvJXoW7CF1xGF4UZFyUGrW8tFyrJFb_yoW8CFy5pF
	WfWFZ2yr1DA343CFs293Z7W34vya1UKrW3CF1agryUAr9Iyrn2kr4Fk3yruFyjkry8C34q
	vr4qgw1UC398AaDanT9S1TB71UUUUUUqnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvEb7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK021l84ACjcxK6xIIjx
	v20xvE14v26w1j6s0DM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26rxl6s0DM28EF7xvwVC2
	z280aVAFwI0_GcCE3s1l84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2AIxVAIcxkEcV
	Aq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8GwAv
	7VCY1x0262k0Y48FwI0_Jr0_Gr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcVAKI48JM4
	IIrI8v6xkF7I0E8cxan2IY04v7Mxk0xIA0c2IEe2xFo4CEbIxvr21lc2xSY4AK67AK6r4U
	MxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_Gr4l4I8I3I0E4IkC6x0Yz7v_Jr
	0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY
	17CE14v26r1q6r43MIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcV
	C0I7IYx2IY6xkF7I0E14v26r4j6F4UMIIF0xvE42xK8VAvwI8IcIk0rVWrJr0_WFyUJwCI
	42IY6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r4j6r4UJbIYCTnIWI
	evJa73UjIFyTuYvjxUfIJmUUUUU
X-CM-SenderInfo: holqwq5zdqw23xof0z/
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/18/19 20:33, Michal Hocko wrote:
>>> +mm_reclaim_congestion_wait_jiffies
>>> +==========
>>> +
>>> +This control is used to define how long kernel will wait/sleep while
>>> +system memory is under pressure and memroy reclaim is relatively active.
>>> +Lower values will decrease the kernel wait/sleep time.
>>> +
>>> +It's suggested to lower this value on high-end box that system is under memory
>>> +pressure but with low storage IO utils and high CPU iowait, which could also
>>> +potentially decrease user application response time in this case.
>>> +
>>> +Keep this control as it were if your box are not above case.
>>> +
>>> +The default value is HZ/10, which is of equal value to 100ms independ of how
>>> +many HZ is defined.
>> Adding a new tunable is not the right solution.  The right way is
>> to make Linux auto-tune itself to avoid the problem.
> I absolutely agree here. From you changelog it is also not clear what is
> the underlying problem. Both congestion_wait and wait_iff_congested
> should wake up early if the congestion is handled. Is this not the case?

For now I don't know why, codes seem should work as you said, maybe I need to
trace more of the internals.
But weird thing is that once I set the people-disliked-tunable iowait
drop down instantly, this is contradictory to the code design.


> Why? Are you sure a shorter timeout is not just going to cause problems
> elsewhere. These sleeps are used to throttle the reclaim. I do agree
> there is no great deal of design behind them so they are more of "let's
> hope it works" kinda thing but making their timeout configurable just
> doesn't solve this at all. You are effectively exporting a very subtle
> implementation detail into the userspace.

Kind of agree, but it does fix the issue at least mine and user response
time also improve in the meantime.
So, just make it as it were and exported to someone needs it..


