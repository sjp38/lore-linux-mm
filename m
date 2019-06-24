Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65755C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:28:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 222E120652
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:28:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 222E120652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2A158E0006; Mon, 24 Jun 2019 11:28:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADB3C8E0002; Mon, 24 Jun 2019 11:28:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F0F18E0006; Mon, 24 Jun 2019 11:28:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72B058E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:28:27 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b1so7562167otk.0
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:28:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=tD9LW0b0iQaF5lKcuMYVOUpAEUh7N54UN8Sooe5594g=;
        b=GfbAFauqNIOBu4LZY6BOztGKn3FUTr85k8T0M9TD2Szjda8SKg0E4tZHlsmRLWWqc3
         sNsg56s92FT5kQPIW8snqBOk4xypCQCUPBCDZxHmOXktu8peIYnBwSomApJA1fybM/w7
         qpynNNpwep3gEJXgaAelM/LtAz4j/BWWwQkAqOXTbutMEDbfWb/oZsPDQh0rZ03KfKQl
         yVGDZelkBdNRVRRQ7xww3SOVeYzLDpHu/G6EYG0Brg1brygE6+LG0jbpjzFoS4OsLWXx
         2l34pm+QwAkTuEaIWD2NMIdv83iND+VhKzDexd8bIfhmH7DkV7Q3qtKG2UllPRtoGzNk
         v/rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXAOZVDQ1KpF4mjDOLsN8VbwlXjJaKuuzrr6cVulkPNR8TG2AyK
	S0lgOr9+MwLS+abMmS7ovqIxz53LFILsNn7Bkl7h5XtpoMTe6nqld4Y1zHR1qENBzxBNsDOfqJv
	hicFUwl2qgFpnbFgkYUH7zi9TnaajOuo4fatd9mq1qaNtziI5U/grl8EaXlD0tuGDhQ==
X-Received: by 2002:aca:c1d4:: with SMTP id r203mr10580734oif.109.1561390107154;
        Mon, 24 Jun 2019 08:28:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYp58XjVVQcQTrzLJJNY+aVcErr9eMDWNd0IvAT481rYmyg+N1KfPyO7hjVbFkAxurB+sz
X-Received: by 2002:aca:c1d4:: with SMTP id r203mr10580693oif.109.1561390106318;
        Mon, 24 Jun 2019 08:28:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561390106; cv=none;
        d=google.com; s=arc-20160816;
        b=xpfDqqgcbo9XAv0d/EhIlV4RhWDwVQVh5jxBi+2SGxJxmxfMzl5YXNFqmpAHf1FI/4
         evekvohOBfE+tUPooIbXI7JjDk5rxp2dH8VX4zjW1lvnXoN+oxfyMTfFm0QugYUngmdT
         /1JZnYQlVCFaIhbCAMnDh5kTCzdC72GE3/KKDbIbtj4UkgS5R+uyew7Nlc+GpxBPufes
         dxc6X5Jfxs4DvPBWlAtaY8gg0zrMwcjmquwWKU01IVxyJw1PZEKyFhCBxDrpJeMCdM25
         FTM/B1v5yG2NkZyLazhZMStc6FeEKPdtEp9+kJ2ZIhNFzHdBP04a9667PxpnLE49ovzv
         dLNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=tD9LW0b0iQaF5lKcuMYVOUpAEUh7N54UN8Sooe5594g=;
        b=f1+RAq3w2rtg1+3/bHnrRl41INziCpBmC9aEq/1mXRF8mLTCeJ+7/fxTMJjQ/Lmhzr
         oDmEalSrD/lcmp+XlGDpaUr8en8VLcaXNuQ6+DL7ypGkZvq6WOgKghAnam7GPsWYhB/k
         HeGEReYdonPK0x7J8l8Ibe4X4kYJThEkdAa6ZrqC+jszs3U4JY9f7qdHKnkeFScz5rYT
         dp+otCvYFSTy4UuO9RmVflzRF4fu0C5flgkpYw7Tbfon18AVoLrOtdnpFhoh56dCCQjm
         USwMCB3rMJPBVK+lSn7E0BiwIgfIA87YiAEsUqbd1s1RSrfq7ZXQKNvbCcx4whnZR+Aj
         12lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 204si6784338oii.169.2019.06.24.08.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 08:28:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id DC1AB725DFA0C932C2BF;
	Mon, 24 Jun 2019 23:28:20 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Mon, 24 Jun 2019
 23:28:11 +0800
Message-ID: <5D10EC0B.1010901@huawei.com>
Date: Mon, 24 Jun 2019 23:28:11 +0800
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
References: <5D1054EE.20402@huawei.com> <20190624081011.GA11400@dhcp22.suse.cz> <5D10CC1B.3080201@huawei.com> <20190624140120.GD11400@dhcp22.suse.cz>
In-Reply-To: <20190624140120.GD11400@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/6/24 22:01, Michal Hocko wrote:
> On Mon 24-06-19 21:11:55, zhong jiang wrote:
>> [  652.272622] sh invoked oom-killer: gfp_mask=0x26080c0, order=3, oom_score_adj=0
>> [  652.272683] CPU: 0 PID: 1748 Comm: sh Tainted: P           O    4.4.171 #8
>> [  653.452827] Mem-Info:
>> [  653.466390] active_anon:20377 inactive_anon:187 isolated_anon:0
>> [  653.466390]  active_file:5087 inactive_file:4825 isolated_file:0
>> [  653.466390]  unevictable:12 dirty:0 writeback:32 unstable:0
>> [  653.466390]  slab_reclaimable:636 slab_unreclaimable:1754
>> [  653.466390]  mapped:5338 shmem:194 pagetables:231 bounce:0
>> [  653.466390]  free:1086 free_pcp:85 free_cma:0
>> [  653.625286] Normal free:4248kB min:1696kB low:2120kB high:2544kB active_anon:81508kB inactive_anon:748kB active_file:20348kB inactive_file:19300kB unevictable:48kB isolated(anon):0kB isolated(file):0kB present:252928kB managed:180496kB mlocked:0kB dirty:0kB writeback:128kB mapped:21352kB shmem:776kB slab_reclaimable:2544kB slab_unreclaimable:7016kB kernel_stack:9856kB pagetables:924kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:392kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>> [  654.177121] lowmem_reserve[]: 0 0 0
>> [  654.462015] Normal: 752*4kB (UME) 128*8kB (UM) 21*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4368kB
>> [  654.601093] 10132 total pagecache pages
>> [  654.606655] 63232 pages RAM
> [...]
>>>> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
>>>> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
>>>> in hardly memory compction.  hence,  it will easily to reproduce the oom.
>>> How get your get such a large fragmentation that you cannot allocate
>>> order-1 pages and compaction is not making any progress?
>> >From the above oom report,  we can see that  there is not order-2 pages.  It wil hardly to allocate kernel stack when
>> creating the process.  And we can easily to reproduce the situation when runing some userspace program.
>>
>> But it rarely trigger the oom when It do not introducing the highatomic.  we test that in the kernel 3.10.
> I do not really see how highatomic reserves could make any difference.
> We do drain them before OOM killer is invoked. The above oom report
> confirms that there is indeed no order-3+ free page to be used.
Unfortunatly,  migrate_highatomic is alway zero,  hence it will not
work for this situation.

Thanks,
zhongjiang
> It is hard to tell whether compaction has done all it could but there
> have many changes in this area since 4.4 so I would be really curious
> about the current upstream kernel behavior. I would also note that
> relying on order-3 allocation is far from optimal. I am not sure what
> exactly copy_process.part.2+0xe4 refers to but if this is really a stack
> allocation then I would consider such a large stack really dangerous for
> a small system.


