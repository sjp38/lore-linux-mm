Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56A53C4CEC9
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 02:20:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 033D621848
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 02:20:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 033D621848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666396B032C; Wed, 18 Sep 2019 22:20:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 617F66B032D; Wed, 18 Sep 2019 22:20:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52BDD6B032E; Wed, 18 Sep 2019 22:20:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2C26B032C
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 22:20:50 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D180C180AD807
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:20:49 +0000 (UTC)
X-FDA: 75950067018.28.moon81_5e5fcd09f4e2b
X-HE-Tag: moon81_5e5fcd09f4e2b
X-Filterd-Recvd-Size: 4970
Received: from wangsu.com (mail.wangsu.com [123.103.51.198])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:20:48 +0000 (UTC)
Received: from localhost.localdomain (unknown [218.85.123.226])
	by app1 (Coremail) with SMTP id xjNnewDnybbs5YJdNFQBAA--.26S2;
	Thu, 19 Sep 2019 10:20:30 +0800 (CST)
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling memory
 reclaim IO congestion_wait length
To: Matthew Wilcox <willy@infradead.org>
Cc: corbet@lwn.net, mcgrof@kernel.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, keescook@chromium.org,
 mchehab+samsung@kernel.org, mgorman@techsingularity.net, vbabka@suse.cz,
 mhocko@suse.com, ktkhai@virtuozzo.com, hannes@cmpxchg.org
References: <20190917115824.16990-1-linf@wangsu.com>
 <20190917120646.GT29434@bombadil.infradead.org>
 <3fbb428e-9466-b56b-0be8-c0f510e3aa99@wangsu.com>
 <20190918113859.GA9880@bombadil.infradead.org>
From: Lin Feng <linf@wangsu.com>
Message-ID: <afb916d8-2c19-f4b7-649f-0d819c2f7e08@wangsu.com>
Date: Thu, 19 Sep 2019 10:20:28 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190918113859.GA9880@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CM-TRANSID:xjNnewDnybbs5YJdNFQBAA--.26S2
X-Coremail-Antispam: 1UD129KBjvJXoW7tF45GF15WFyxZFWUJrW3Awb_yoW8tw17pF
	y8tFsFgF4qyr93tr92va47Kw1Ut3yUGrW7Jry3X34Uu3s8JF92vF4IgayY9asxurn3Gry2
	vr4j934kZrWYvaDanT9S1TB71UUUUUUqnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
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
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 9/18/19 19:38, Matthew Wilcox wrote:
> On Wed, Sep 18, 2019 at 11:21:04AM +0800, Lin Feng wrote:
>>> Adding a new tunable is not the right solution.  The right way is
>>> to make Linux auto-tune itself to avoid the problem.  For example,
>>> bdi_writeback contains an estimated write bandwidth (calculated by the
>>> memory management layer).  Given that, we should be able to make an
>>> estimate for how long to wait for the queues to drain.
>>>
>>
>> Yes, I had ever considered that, auto-tuning is definitely the senior AI way.
>> While considering all kinds of production environments hybird storage solution
>> is also common today, servers' dirty pages' bdi drivers can span from high end
>> ssds to low end sata disk, so we have to think of a *formula(AI core)* by using
>> the factors of dirty pages' amount and bdis' write bandwidth, and this AI-core
>> will depend on if the estimated write bandwidth is sane and moreover the to be
>> written back dirty pages is sequential or random if the bdi is rotational disk,
>> it's likey to give a not-sane number and hurt guys who dont't want that, while
>> if only consider ssd is relatively simple.
>>
>> So IMHO it's not sane to brute force add a guessing logic into memory writeback
>> codes and pray on inventing a formula that caters everyone's need.
>> Add a sysctl entry may be a right choice that give people who need it and
>> doesn't hurt people who don't want it.
> 
> You're making this sound far harder than it is.  All the writeback code
> needs to know is "How long should I sleep for in order for the queues
> to drain a substantial amount".  Since you know the bandwidth and how
> many pages you've queued up, it's a simple calculation.
> 

Ah, I should have read more of the writeback codes ;-)
Based on Michal's comments:
 > the underlying problem. Both congestion_wait and wait_iff_congested
 > should wake up early if the congestion is handled. Is this not the case?
If process is waken up once bdi congested is clear, this timeout length's role
seems not that important. I need to trace more if I can reproduce this issue
without online network traffic. But still weird thing is that once I set the
people-disliked-tunable iowait drop down instantly, they are contradictory.

Anyway, thanks a lot for your suggestions!
linfeng


