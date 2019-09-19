Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5CAFC49ED7
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 07:46:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFA7621A49
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 07:46:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFA7621A49
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 438EC6B0342; Thu, 19 Sep 2019 03:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E9046B0344; Thu, 19 Sep 2019 03:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FF616B0345; Thu, 19 Sep 2019 03:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7706B0342
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 03:46:35 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A96A4180AD805
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 07:46:34 +0000 (UTC)
X-FDA: 75950887908.29.shape22_1c22e0211752b
X-HE-Tag: shape22_1c22e0211752b
X-Filterd-Recvd-Size: 5870
Received: from wangsu.com (mail.wangsu.com [123.103.51.198])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 07:46:32 +0000 (UTC)
Received: from localhost.localdomain (unknown [218.85.123.226])
	by app1 (Coremail) with SMTP id xjNnewD32LVDMoNdB8kCAA--.186S2;
	Thu, 19 Sep 2019 15:46:12 +0800 (CST)
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling memory
 reclaim IO congestion_wait length
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, corbet@lwn.net, mcgrof@kernel.org,
 akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 keescook@chromium.org, mchehab+samsung@kernel.org,
 mgorman@techsingularity.net, vbabka@suse.cz, ktkhai@virtuozzo.com,
 hannes@cmpxchg.org, Jens Axboe <axboe@kernel.dk>,
 Omar Sandoval <osandov@fb.com>, Ming Lei <ming.lei@redhat.com>
References: <20190917115824.16990-1-linf@wangsu.com>
 <20190917120646.GT29434@bombadil.infradead.org>
 <20190918123342.GF12770@dhcp22.suse.cz>
 <6ae57d3e-a3f4-a3db-5654-4ec6001941a9@wangsu.com>
 <20190919034949.GF9880@bombadil.infradead.org>
From: Lin Feng <linf@wangsu.com>
Message-ID: <33090db5-c7d4-8d7d-0082-ee7643d15775@wangsu.com>
Date: Thu, 19 Sep 2019 15:46:11 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190919034949.GF9880@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CM-TRANSID:xjNnewD32LVDMoNdB8kCAA--.186S2
X-Coremail-Antispam: 1UD129KBjvJXoWxGw4furW7Cr4UCryrZF4DXFb_yoW5GF43pr
	yj9ryvyr4jvryayrs7Za4xX34Fyw17Kr4fJr1Yg3sxA345CFya9F1UK3s09FWfurn7Za4j
	qr4Uu34xuwn8ArJanT9S1TB71UUUUUUqnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvKb7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK021l84ACjcxK6xIIjx
	v20xvE14v26w1j6s0DM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26rxl6s0DM28EF7xvwVC2
	z280aVAFwI0_GcCE3s1l84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2AIxVAIcxkEcV
	Aq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8GwAv
	7VCY1x0262k0Y48FwI0_Jr0_Gr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcVAKI48JM4
	IIrI8v6xkF7I0E8cxan2IY04v7Mxk0xIA0c2IEe2xFo4CEbIxvr21lc2xSY4AK67AK6r4x
	MxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_Gr4l4I8I3I0E4IkC6x0Yz7v_Jr
	0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY
	17CE14v26r4a6rW5MIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcV
	C0I7IYx2IY6xkF7I0E14v26r4j6F4UMIIF0xvE42xK8VAvwI8IcIk0rVWrZr1j6s0DMIIF
	0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr0_Gr1UYxBIdaVFxh
	VjvjDU0xZFpf9x07jWa0PUUUUU=
X-CM-SenderInfo: holqwq5zdqw23xof0z/
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/19/19 11:49, Matthew Wilcox wrote:
> On Thu, Sep 19, 2019 at 10:33:10AM +0800, Lin Feng wrote:
>> On 9/18/19 20:33, Michal Hocko wrote:
>>> I absolutely agree here. From you changelog it is also not clear what is
>>> the underlying problem. Both congestion_wait and wait_iff_congested
>>> should wake up early if the congestion is handled. Is this not the case?
>>
>> For now I don't know why, codes seem should work as you said, maybe I need to
>> trace more of the internals.
>> But weird thing is that once I set the people-disliked-tunable iowait
>> drop down instantly, this is contradictory to the code design.
> 
> Yes, this is quite strange.  If setting a smaller timeout makes a
> difference, that indicates we're not waking up soon enough.  I see
> two possibilities; one is that a wakeup is missing somewhere -- ie the
> conditions under which we call clear_wb_congested() are wrong.  Or we
> need to wake up sooner.
> 
> Umm.  We have clear_wb_congested() called from exactly one spot --
> clear_bdi_congested().  That is only called from:
> 
> drivers/block/pktcdvd.c
> fs/ceph/addr.c
> fs/fuse/control.c
> fs/fuse/dev.c
> fs/nfs/write.c
> 
> Jens, is something supposed to be calling clear_bdi_congested() in the
> block layer?  blk_clear_congested() used to exist until October 29th
> last year.  Or is something else supposed to be waking up tasks that
> are sleeping on congestion?
> 

IIUC it looks like after commit a1ce35fa49852db60fc6e268038530be533c5b15,
besides those *.c places as you mentioned above, vmscan codes will always
wait as long as 100ms and nobody wakes them up.

here:
1964         while (unlikely(too_many_isolated(pgdat, file, sc))) {
1965                 if (stalled)
1966                         return 0;
1967
1968                 /* wait a bit for the reclaimer. */
 >1969                 msleep(100);
1970                 stalled = true;
1971
1972                 /* We are about to die and free our memory. Return now. */
1973                 if (fatal_signal_pending(current))
1974                         return SWAP_CLUSTER_MAX;
1975         }

and here:
2784                         /*
2785                          * If kswapd scans pages marked marked for immediate
2786                          * reclaim and under writeback (nr_immediate), it
2787                          * implies that pages are cycling through the LRU
2788                          * faster than they are written so also forcibly stall.
2789                          */
2790                         if (sc->nr.immediate)
 >2791                                 congestion_wait(BLK_RW_ASYNC, HZ/10);
2792                 }

except here, codes where set_bdi_congested will clear_bdi_congested at proper time,
exactly the source files you mentioned above, so it's OK.
2808                 if (!sc->hibernation_mode && !current_is_kswapd() &&
2809                    current_may_throttle() && pgdat_memcg_congested(pgdat, root))
2810                         wait_iff_congested(BLK_RW_ASYNC, HZ/10);



