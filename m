Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28ADDC48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE3AB204EC
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:47:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE3AB204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 745E66B0005; Mon, 24 Jun 2019 12:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6768E0003; Mon, 24 Jun 2019 12:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E56E8E0002; Mon, 24 Jun 2019 12:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32A046B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 12:47:25 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 31so2042194otv.6
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=B+ZthcBz2ItCxjLSKkRBY6FGZvtkkSFWw3IhtIy6h/8=;
        b=fohfArW7NpLadCA0jaFstrCOA9/aToV4pPiRHdFgBWO7oeunlQCgR6w9E2JdHe9fvt
         Hynl20BCq/X2tdydQmBBiOGebrqY3hooq/gB493sj+TiKkNSw4oo6bWPcc/2IrHpfiTz
         l19tGm2HZBlSCfRTlipPNYSGPnfPJQBinGJTGu0XSvUa51f/CXI3+fbxYOPx+nSQXXmS
         s0nTA47wt1rdcVlmo5xp0Au+/JHcriJwZmLszFe9leXZnXDMMIRNbGiVFj3xDcaMBs2s
         lIvHBBlg80vscQ1wHtRKRM9/BsL3bNV4gUN1/cEXK0V7XB6oBLLTXITfA2Jt7+FunOBc
         cbJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAVV9RLNRvzgqYGmTDpFcpwXeZfESfXSQLUqNh9awfzKkf/BOEG5
	ZEb1F0u4DQNlk4/UPljl2C69/I87AmrhM0xrQwqKHqg2Hug2mp9C2fYivx8MfadIRyKDilHKrTU
	NSAdm4vjLgOcv1hsI385y9auRuQ9RAXnWGejNL+ZfMD+zT/X9FQmvjQd+7IeIcfg9vQ==
X-Received: by 2002:a05:6830:1303:: with SMTP id p3mr26917010otq.267.1561394844839;
        Mon, 24 Jun 2019 09:47:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2Wdr/5SC6S73+TXaWndHjbQwBs+lw+3cFvk5MEeTU7Se2+Rz6qTljqqlB1fOlH1UHjR3Y
X-Received: by 2002:a05:6830:1303:: with SMTP id p3mr26916976otq.267.1561394843843;
        Mon, 24 Jun 2019 09:47:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561394843; cv=none;
        d=google.com; s=arc-20160816;
        b=sE/DWN9WTBXeBFuJnmlVGVHCWKo6MVwnJaoaTDxZ9t6vKdmlRjGpu4PcEcewnNfVoJ
         l7z420toPsEz3g/j+otc79nlv65dX2+9w6nwx0FRWzH0iFiH9RHSuyJvQiCIPiLlFJCY
         N7jt81QFtTIuCWFnT5Y44NPJ933kKxuYi+bkKgtlgRSI7g1xq0ZcMfZG2KkqJE+1XTiX
         YIsvyZ68L9a5IJEzqtg7wxRLZ0GPuGNkPTxVe/CvRAAlUlUv7zFJNIWXcM2V6S896FCX
         VEy2Vc/xuQn0mPbG3XlJsFCk0S3N0im5+b3m8A/VFTibI1GyXIy6N2QJ8/AaQyOHq/Gv
         IgHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=B+ZthcBz2ItCxjLSKkRBY6FGZvtkkSFWw3IhtIy6h/8=;
        b=f2sw8sn9PmCOpn/QqQBW2KO8T59ykguXlisHQF9AeM+o4qBnQI6239YQ5eoau4LoFL
         pRcKJJYNIiKjf4ZN9DOfW/97Oxb9GL772Z0wDBpb59PtMZo6wV4GzNGtUsYfJ6oaQ3lM
         Uio7ZguHXWrGZQYgCZHugQXV03Na4Ox7l/SA/ezUIRwgVwBvjLZseD5L+r+1rAdca7y+
         Yp5SePHaagcyaU2FToIc3VqNOc/t6V4/FT4nf3vZzxOy/MRnVcsAqQLI/Ss+HKya+U/I
         XMBRyb49PWIwRHKzRMGmJbo5o46E+/Vv6U+QzsZdm/qHtI0a5QkgVgYvApfZhCxPqRYY
         m7qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id n204si6442207oib.268.2019.06.24.09.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 09:47:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 4BF531069B65B09F8C64;
	Tue, 25 Jun 2019 00:47:19 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.439.0; Tue, 25 Jun 2019
 00:47:12 +0800
Message-ID: <5D10FE8F.2010906@huawei.com>
Date: Tue, 25 Jun 2019 00:47:11 +0800
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
I mean that all order with migrate_highatomic is alway zero,  it can be  true that
we can not reserve the high order memory if we do not use gfp_atomic to allocate memory.

Thought?

Thanks,
zhong jiang
>
> It is hard to tell whether compaction has done all it could but there
> have many changes in this area since 4.4 so I would be really curious
> about the current upstream kernel behavior. I would also note that
> relying on order-3 allocation is far from optimal. I am not sure what
> exactly copy_process.part.2+0xe4 refers to but if this is really a stack
> allocation then I would consider such a large stack really dangerous for
> a small system.


