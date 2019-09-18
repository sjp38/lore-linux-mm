Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB884C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 03:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76B2220862
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 03:21:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76B2220862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AC186B0275; Tue, 17 Sep 2019 23:21:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05D0F6B0276; Tue, 17 Sep 2019 23:21:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8D006B0277; Tue, 17 Sep 2019 23:21:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0190.hostedemail.com [216.40.44.190])
	by kanga.kvack.org (Postfix) with ESMTP id C00296B0275
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 23:21:26 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3A5C14835
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:21:26 +0000 (UTC)
X-FDA: 75946590972.09.hands57_80c8a94145745
X-HE-Tag: hands57_80c8a94145745
X-Filterd-Recvd-Size: 5891
Received: from wangsu.com (mail.wangsu.com [123.103.51.198])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:21:24 +0000 (UTC)
Received: from [10.8.148.37] (unknown [218.85.123.226])
	by app1 (Coremail) with SMTP id xjNnewCHZ9CgooFdnSR5AA--.80S2;
	Wed, 18 Sep 2019 11:21:06 +0800 (CST)
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling memory
 reclaim IO congestion_wait length
To: Matthew Wilcox <willy@infradead.org>
Cc: corbet@lwn.net, mcgrof@kernel.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, keescook@chromium.org,
 mchehab+samsung@kernel.org, mgorman@techsingularity.net, vbabka@suse.cz,
 mhocko@suse.com, ktkhai@virtuozzo.com, hannes@cmpxchg.org
References: <20190917115824.16990-1-linf@wangsu.com>
 <20190917120646.GT29434@bombadil.infradead.org>
From: Lin Feng <linf@wangsu.com>
Message-ID: <3fbb428e-9466-b56b-0be8-c0f510e3aa99@wangsu.com>
Date: Wed, 18 Sep 2019 11:21:04 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190917120646.GT29434@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CM-TRANSID:xjNnewCHZ9CgooFdnSR5AA--.80S2
X-Coremail-Antispam: 1UD129KBjvJXoWxWF1UKw15Zw48ury3ZF1xuFg_yoW5urykpF
	WxKFZ3Ka1UAry3tFs2y3Zrur1Fqay8Ary3Jr98Wry5Ary5ZF1IkFWfKF4YvFyxCrn3Cr9I
	vr45u3srur4YyFJanT9S1TB71UUUUUUqnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvKb7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK021l84ACjcxK6xIIjx
	v20xvE14v26w1j6s0DM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26rxl6s0DM28EF7xvwVC2
	z280aVAFwI0_GcCE3s1l84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2AIxVAIcxkEcV
	Aq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8GwAv
	7VCY1x0262k0Y48FwI0_Gr0_Cr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcVAKI48JM4
	IIrI8v6xkF7I0E8cxan2IY04v7Mxk0xIA0c2IEe2xFo4CEbIxvr21lc2xSY4AK67AK6r48
	MxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_Gr4l4I8I3I0E4IkC6x0Yz7v_Jr
	0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY
	17CE14v26r1q6r43MIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcV
	C0I7IYx2IY6xkF7I0E14v26r4j6F4UMIIF0xvE42xK8VAvwI8IcIk0rVWrZr1j6s0DMIIF
	0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr0_Gr1UYxBIdaVFxh
	VjvjDU0xZFpf9x07j_XocUUUUU=
X-CM-SenderInfo: holqwq5zdqw23xof0z/
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/17/19 20:06, Matthew Wilcox wrote:
> On Tue, Sep 17, 2019 at 07:58:24PM +0800, Lin Feng wrote:
>> In direct and background(kswapd) pages reclaim paths both may fall into
>> calling msleep(100) or congestion_wait(HZ/10) or wait_iff_congested(HZ/10)
>> while under IO pressure, and the sleep length is hard-coded and the later
>> two will introduce 100ms iowait length per time.
>>
>> So if pages reclaim is relatively active in some circumstances such as high
>> order pages reappings, it's possible to see a lot of iowait introduced by
>> congestion_wait(HZ/10) and wait_iff_congested(HZ/10).
>>
>> The 100ms sleep length is proper if the backing drivers are slow like
>> traditionnal rotation disks. While if the backing drivers are high-end
>> storages such as high iops ssds or even faster drivers, the high iowait
>> inroduced by pages reclaim is really misleading, because the storage IO
>> utils seen by iostat is quite low, in this case the congestion_wait time
>> modified to 1ms is likely enough for high-end ssds.
>>
>> Another benifit is that it's potentially shorter the direct reclaim blocked
>> time when kernel falls into sync reclaim path, which may improve user
>> applications response time.
> 
> This is a great description of the problem.
The always 100ms blocked time sometimes is not necessary :)

> 
>> +mm_reclaim_congestion_wait_jiffies
>> +==========
>> +
>> +This control is used to define how long kernel will wait/sleep while
>> +system memory is under pressure and memroy reclaim is relatively active.
>> +Lower values will decrease the kernel wait/sleep time.
>> +
>> +It's suggested to lower this value on high-end box that system is under memory
>> +pressure but with low storage IO utils and high CPU iowait, which could also
>> +potentially decrease user application response time in this case.
>> +
>> +Keep this control as it were if your box are not above case.
>> +
>> +The default value is HZ/10, which is of equal value to 100ms independ of how
>> +many HZ is defined.
> 
> Adding a new tunable is not the right solution.  The right way is
> to make Linux auto-tune itself to avoid the problem.  For example,
> bdi_writeback contains an estimated write bandwidth (calculated by the
> memory management layer).  Given that, we should be able to make an
> estimate for how long to wait for the queues to drain.
> 

Yes, I had ever considered that, auto-tuning is definitely the senior AI way.
While considering all kinds of production environments hybird storage solution
is also common today, servers' dirty pages' bdi drivers can span from high end
ssds to low end sata disk, so we have to think of a *formula(AI core)* by using
the factors of dirty pages' amount and bdis' write bandwidth, and this AI-core
will depend on if the estimated write bandwidth is sane and moreover the to be
written back dirty pages is sequential or random if the bdi is rotational disk,
it's likey to give a not-sane number and hurt guys who dont't want that, while
if only consider ssd is relatively simple.

So IMHO it's not sane to brute force add a guessing logic into memory writeback
codes and pray on inventing a formula that caters everyone's need.
Add a sysctl entry may be a right choice that give people who need it and
doesn't hurt people who don't want it.

thanks,
linfeng


