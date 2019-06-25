Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A41BC4646B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 02:52:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3DFB20652
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 02:52:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3DFB20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A8A46B0003; Mon, 24 Jun 2019 22:52:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5312E8E0003; Mon, 24 Jun 2019 22:52:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F8F88E0002; Mon, 24 Jun 2019 22:52:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13A956B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 22:52:32 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a8so8392502oti.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 19:52:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=2ct1JEOPbK/oq6Rx4H3L48Xnc9tYl30SRktt09LGxzw=;
        b=ZNjddzzo1vBYtCWYmNegmZCsidD99MY04WtoBWqdXanKEHYQhZZ+AAi14kg7uZj/c1
         4Zx5moB8HPEy52d0e8I+1v4zuiWxD8udXcCL4lHFhw2zclY5c3jGZ1x7r7AGHBnrUr3V
         Q7I2L5RuNDUFOeAEUTe77xLiOWDGc57j6RhFoURcP0NRjd/B+wzGv0uBqjRt/tpILai3
         FRWmMSPBLEv6t69/j7eWWHjV7vLM10aW65Axy+hA4yxgsAnqn335kTGwAob3oXtcjBfS
         rg9tvFF3E7Wi3Jv5vFmyHZUVI1yUhy7da3Lq/kEkueAMTjn4/2r7yVYeFCa1cFRG9aFa
         fEEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXlgpIUEiYASKLhCe0ZfmYXP5Br2cEgdx1kRCqdH+cH4vyJMXUh
	2t4phxsD8aiwVqyX4dURr3w08Q+LRHbQkDd3x4wmavFGc5vIVNeCGYVUlujwrr8BcDM4AqWnL2C
	pIW5A7q28SWigLc3d6X+H4R58EJb8qwlwAcGACs+W5l5GuCs8uHI5MCKtUhuOZW+HsA==
X-Received: by 2002:a05:6830:93:: with SMTP id a19mr33086904oto.127.1561431151589;
        Mon, 24 Jun 2019 19:52:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTauQj/RDiJ+7j0a4pp2AjgrG+/D6uBxlrQiFcpAjuFR1NoefVAg4924yor1Ut95hNQhZ5
X-Received: by 2002:a05:6830:93:: with SMTP id a19mr33086868oto.127.1561431150813;
        Mon, 24 Jun 2019 19:52:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561431150; cv=none;
        d=google.com; s=arc-20160816;
        b=HGxQpmlHd8VVqieM9LeF8ib2lkIT6NMz0dv1bpCmmzfKk8zuYajwhhwOmJ9T5M2JXz
         IURgsnsozCtStaSbWRQ54rmyWPLi0xKe5VesN0D2dLNFK9D78m44ozuUG/NZwWMCR8iI
         fn5vQHoiPw7dkZCjfS0vlUlLMV5FNLawcgGy0obZlGpnIqwN5LCuZ5X6ZvaagCZBdpHu
         kn44AQCKqttYJK3N8aibbIcUXBJ6JAudCPcsUv5SoOZ2gBLwFTo9O3glrp1JOoKxlmkT
         qRRnlVoJQAL3LAXUhC5XGbCrcPjSNCe+eelRoqCpmzP9QEP6IfjZe6Vevvh5ojQm3IPK
         55zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=2ct1JEOPbK/oq6Rx4H3L48Xnc9tYl30SRktt09LGxzw=;
        b=a1xG175wNvsFgwHPZ3iVFKnYyK7zkziZc9AyJ1wRaZK5CT4uAKORJ22ozsLPk63Ex+
         aWl98JTSWucXheStjO8BAd7uB4ObfvrRYaPxBsKgRqYMJTK5lvsYxGIovC1ENxnukP7m
         gyFBGZRpDWeOtAoPengNltrh4OK6keL4PhypjNqBmTbLo6DjP4F7E3oT42Iw/OMIHRfk
         fdCovTLY7jgKPUaESCMUxB7W3bTblCAgZeCX00jPMk2lPcnp9EFp6wYKK0b80SnW2wAH
         qaNcyfZCoVdjFiD0P7NhL69Ox4x118ZNkO9q4R3nyPmtiXjpWPpHTVCXDDI32ApyAIz3
         1bxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id h23si8427001otr.292.2019.06.24.19.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 19:52:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 7F3AA7D34BEAABD75BE0;
	Tue, 25 Jun 2019 10:52:25 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.439.0; Tue, 25 Jun 2019
 10:52:17 +0800
Message-ID: <5D118C61.7040308@huawei.com>
Date: Tue, 25 Jun 2019 10:52:17 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Michal Hocko <mhocko@kernel.org>
CC: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "Linux
 Memory Management List" <linux-mm@kvack.org>, "Wangkefeng (Kevin)"
	<wangkefeng.wang@huawei.com>
Subject: Re: Frequent oom introduced in mainline when migrate_highatomic replace
 migrate_reserve
References: <5D1054EE.20402@huawei.com> <20190624081011.GA11400@dhcp22.suse.cz> <5D10CC1B.3080201@huawei.com> <20190624140120.GD11400@dhcp22.suse.cz> <5D10FE8F.2010906@huawei.com> <20190624175448.GG11400@dhcp22.suse.cz>
In-Reply-To: <20190624175448.GG11400@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/6/25 1:54, Michal Hocko wrote:
> On Tue 25-06-19 00:47:11, zhong jiang wrote:
>> On 2019/6/24 22:01, Michal Hocko wrote:
>>> On Mon 24-06-19 21:11:55, zhong jiang wrote:
>>>> [  652.272622] sh invoked oom-killer: gfp_mask=0x26080c0, order=3, oom_score_adj=0
>>>> [  652.272683] CPU: 0 PID: 1748 Comm: sh Tainted: P           O    4.4.171 #8
>>>> [  653.452827] Mem-Info:
>>>> [  653.466390] active_anon:20377 inactive_anon:187 isolated_anon:0
>>>> [  653.466390]  active_file:5087 inactive_file:4825 isolated_file:0
>>>> [  653.466390]  unevictable:12 dirty:0 writeback:32 unstable:0
>>>> [  653.466390]  slab_reclaimable:636 slab_unreclaimable:1754
>>>> [  653.466390]  mapped:5338 shmem:194 pagetables:231 bounce:0
>>>> [  653.466390]  free:1086 free_pcp:85 free_cma:0
>>>> [  653.625286] Normal free:4248kB min:1696kB low:2120kB high:2544kB active_anon:81508kB inactive_anon:748kB active_file:20348kB inactive_file:19300kB unevictable:48kB isolated(anon):0kB isolated(file):0kB present:252928kB managed:180496kB mlocked:0kB dirty:0kB writeback:128kB mapped:21352kB shmem:776kB slab_reclaimable:2544kB slab_unreclaimable:7016kB kernel_stack:9856kB pagetables:924kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:392kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>>>> [  654.177121] lowmem_reserve[]: 0 0 0
>>>> [  654.462015] Normal: 752*4kB (UME) 128*8kB (UM) 21*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4368kB
>>>> [  654.601093] 10132 total pagecache pages
>>>> [  654.606655] 63232 pages RAM
>>> [...]
>>>>>> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
>>>>>> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
>>>>>> in hardly memory compction.  hence,  it will easily to reproduce the oom.
>>>>> How get your get such a large fragmentation that you cannot allocate
>>>>> order-1 pages and compaction is not making any progress?
>>>> >From the above oom report,  we can see that  there is not order-2 pages.  It wil hardly to allocate kernel stack when
>>>> creating the process.  And we can easily to reproduce the situation when runing some userspace program.
>>>>
>>>> But it rarely trigger the oom when It do not introducing the highatomic.  we test that in the kernel 3.10.
>>> I do not really see how highatomic reserves could make any difference.
>>> We do drain them before OOM killer is invoked. The above oom report
>>> confirms that there is indeed no order-3+ free page to be used.
>> I mean that all order with migrate_highatomic is alway zero,  it can be  true that
> Yes, highatomic is meant to be used for higher order allocations which
> already do have access to memory reserves. E.g. via __GFP_ATOMIC.
If current kernel have not use __GFP_ATOMIC to allocate memory,  highatomic will have not available higher order.
And we have order-3 kernel stack allocation requirement in the system.  

There is not  memory reserve to use for us in the emergency situation,  which is different from migrate_reserve.
Maybe I  think that we can change the reserve memory behaviour,  Not only reserve higher order in GFP_ATOMIC.

Thanks,
zhong jiang




