Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5A5AC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:12:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97688204EC
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:12:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97688204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 352468E0006; Mon, 24 Jun 2019 09:12:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DC588E0002; Mon, 24 Jun 2019 09:12:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A3EC8E0006; Mon, 24 Jun 2019 09:12:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E345D8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:12:21 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f36so7364303otf.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:12:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=TQL0kWvxEjgFtGg2pcyhGx/m0O4ciIiYgmrGwo35dKA=;
        b=DQbqY6MwSePQUsxxN6TtcLxt00pbszjw8SNFOJwdud4jODFVycc55tCJpTt1qBr8Na
         YijtcrM7wOJ7voyhgVkKc+6pz9QThsDrVD5kNTjfy6y0TUohdPR3IHOoFpnOvOOtxEEa
         XnzvZlF5ZAqkC+I4DLXZvjTP8Dt92GfRZGGqnxgjOEE5UMmSADSCQ06GldO5a902x9a5
         WUQFYoV7kFAhgwyAO4T7TcTniiXlTff+AQ0Y4xht7NNev2l9hsWEoauu8Db/YZfkJmB5
         3mRbGHq8egnommw+RhIBpBXB9FikHF87ZkgMXlTGgOhS7eaR3fFpaDFfDM2dR2gFxzr/
         ee2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAVKgnFi2Reg64+dJ6Ec7VTQ1Fy8Ww5AOkbvgiAlHqWF/dpXnhlk
	dfUCSlY9f9X8f1kfqyO/devv1my+61vPUvzW0+ODF9hjU3dH1e9yx194KaxpfFAbbyznUuRSKww
	nM4upm5+KPka9/voosCNiBaD+CT2/qs4CiuT5x9TnUlA8UoppjlSy/pUfbM6/LBPIAQ==
X-Received: by 2002:aca:fd04:: with SMTP id b4mr10152204oii.53.1561381941542;
        Mon, 24 Jun 2019 06:12:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIt7rVyA9ape0eFnij8ey2TJt+BLO27iqQ6+XUc8p5r9uAOMzILALg0NkGWBSTViKIoZvB
X-Received: by 2002:aca:fd04:: with SMTP id b4mr10152153oii.53.1561381940636;
        Mon, 24 Jun 2019 06:12:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381940; cv=none;
        d=google.com; s=arc-20160816;
        b=KtMqLbxbfcF70gHsnmEmvbJgI6zsTEGTOQoUtMbOCP17DiMXQSIeSgUYTI9LhGf2b4
         sGuAI5rUOO5JlbWrmZtW4dZjDfjbf8aWX/27o8z7PVc84Ju445PIMNOu3doVedajdKzH
         YPIVkr0rgWLodAQgQVpSRsju3WjvmNhjX2WNSxPcrOb0bnETrSAHpyQn37VQFQPBTUgt
         J4FPWteVKQyG3zh4f8n5kqCJJ11vVzCS1WySQEXBvERnCbAfGTS7C+jZga3cGB9GhTZz
         9DtrxfS9zoSRZ69y6jyx7eRGSH+AulesBwa6Ip47UoNtcfcOya+C8NiXyT3SSViLJKo6
         o6Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=TQL0kWvxEjgFtGg2pcyhGx/m0O4ciIiYgmrGwo35dKA=;
        b=mqC92oJcWCFfAHAH2r8ampvQcW+IKQl9P3+qxIjqQ26TjU/abQFdkDN7m80BNz7am2
         boaafeV1uBpCccxkpjFd83XoFtY6b3DxNv/1E2u0Ripd1zWa6E/bjTVRwPGuxMvihUV/
         hfZsQ76WAMlxhDf3w4WrswiuPKuoQQc40pFf8bUttQGC5y89rm1wxVQaO8hXprWBbtq/
         5ETFwZ7v9EcGMZ/2IPhBSdcLXQcJLrqeE5TjKVC3cavjm/3VBJnbcF8+5bEIvR4+brGO
         SwCcW1D9EYG1TYGtBdn9NEOhLe99vXqgsAtE/uxonI0TC3M+mmX/9zWeRcFHdfLgmC0l
         /Fyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id s133si6573859oie.9.2019.06.24.06.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 06:12:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id E682691E5F83DCDDE5B0;
	Mon, 24 Jun 2019 21:12:13 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.439.0; Mon, 24 Jun 2019
 21:11:56 +0800
Message-ID: <5D10CC1B.3080201@huawei.com>
Date: Mon, 24 Jun 2019 21:11:55 +0800
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
References: <5D1054EE.20402@huawei.com> <20190624081011.GA11400@dhcp22.suse.cz>
In-Reply-To: <20190624081011.GA11400@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/6/24 16:10, Michal Hocko wrote:
> On Mon 24-06-19 12:43:26, zhong jiang wrote:
>> Recently,  I  hit an frequent oom issue in linux-4.4 stable with less than 4M free memory after
>> the machine boots up.
> Is this is a regression? Could you share the oom report?
Yep,  At least at the small memory machine.  I has tested that revert the migrate_highatomic  works well. 
The oom report message is as follows.

[  652.272622] sh invoked oom-killer: gfp_mask=0x26080c0, order=3, oom_score_adj=0
[  652.272683] CPU: 0 PID: 1748 Comm: sh Tainted: P           O    4.4.171 #8
[  652.345605] Hardware name: Qualcomm (Flattened Device Tree)
[  652.428968] [<c02149d0>] (unwind_backtrace) from [<c02125a4>] (show_stack+0x10/0x14)
[  652.494604] [<c02125a4>] (show_stack) from [<c037fb08>] (dump_stack+0xa0/0xd8)
[  652.590432] [<c037fb08>] (dump_stack) from [<c02bdf58>] (dump_header.constprop.6+0x40/0x15c)
[  652.674793] [<c02bdf58>] (dump_header.constprop.6) from [<c0287504>] (oom_kill_process+0xc4/0x434)
[  652.777934] [<c0287504>] (oom_kill_process) from [<c0287b5c>] (out_of_memory+0x284/0x318)
[  652.883120] [<c0287b5c>] (out_of_memory) from [<c028b990>] (__alloc_pages_nodemask+0x90c/0x9b4)
[  652.982080] [<c028b990>] (__alloc_pages_nodemask) from [<c021aa94>] (copy_process.part.2+0xe4/0x12f0)
[  653.084160] [<c021aa94>] (copy_process.part.2) from [<c021bdf8>] (_do_fork+0xb8/0x2d4)
[  653.196678] [<c021bdf8>] (_do_fork) from [<c021c0d0>] (SyS_clone+0x1c/0x24)
[  653.290424] [<c021c0d0>] (SyS_clone) from [<c020f480>] (ret_fast_syscall+0x0/0x4c)
[  653.452827] Mem-Info:
[  653.466390] active_anon:20377 inactive_anon:187 isolated_anon:0
[  653.466390]  active_file:5087 inactive_file:4825 isolated_file:0
[  653.466390]  unevictable:12 dirty:0 writeback:32 unstable:0
[  653.466390]  slab_reclaimable:636 slab_unreclaimable:1754
[  653.466390]  mapped:5338 shmem:194 pagetables:231 bounce:0
[  653.466390]  free:1086 free_pcp:85 free_cma:0
[  653.625286] Normal free:4248kB min:1696kB low:2120kB high:2544kB active_anon:81508kB inactive_anon:748kB active_file:20348kB inactive_file:19300kB unevictable:48kB isolated(anon):0kB isolated(file):0kB present:252928kB managed:180496kB mlocked:0kB dirty:0kB writeback:128kB mapped:21352kB shmem:776kB slab_reclaimable:2544kB slab_unreclaimable:7016kB kernel_stack:9856kB pagetables:924kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:392kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  654.177121] lowmem_reserve[]: 0 0 0
[  654.462015] Normal: 752*4kB (UME) 128*8kB (UM) 21*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4368kB
[  654.601093] 10132 total pagecache pages
[  654.606655] 63232 pages RAM
[  654.656658] 0 pages HighMem/MovableOnly
[  654.686821] 18108 pages reserved
[  654.731549] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  654.775019] [  108]     0   108      814       11       6       0        0             0 rcS
[  654.877730] [  113]     0   113      814      125       6       0        0             0 sh
[  654.978510] [  116]     0   116      485       16       5       0        0             0 fprefetch
[  655.083679] [  272]     0   272     1579       83       7       0        0         -1000 sshd
[  655.187516] [  276]     0   276     7591      518      10       0        0             0 redis-server
[  655.287893] [  282]     0   282     3495      364       8       0        0             0 callhome
[  655.406249] [  284]     0   284     1166      322       6       0        0             0 remote_plugin
[  655.524594] [  292]     0   292      523      113       6       0        0           -17 monitor
[  655.616477] [  293]     0   293    17958      609      39       0        0             0 cap32
[  655.724315] [  296]     0   296     2757     1106      10       0        0             0 confd
[  655.823061] [  297]     0   297    60183    20757     112       0        0             0 vos.o
[  655.952344] [ 1748]     0  1748      814       92       6       0        0             0 sh
......[  656.241027] *****************Start oom extend info.*****************
>> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
>> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
>> in hardly memory compction.  hence,  it will easily to reproduce the oom.
> How get your get such a large fragmentation that you cannot allocate
> order-1 pages and compaction is not making any progress?
From the above oom report,  we can see that  there is not order-2 pages.  It wil hardly to allocate kernel stack when
creating the process.  And we can easily to reproduce the situation when runing some userspace program.

But it rarely trigger the oom when It do not introducing the highatomic.  we test that in the kernel 3.10.
>> But if we use migrate_reserve to reserve at least a pageblock at  the boot stage.   we can use
>> the reserve memory to allocate continuous memory for process when the system is under
>> severerly fragmentation.
> Well, any reservation is a finite resource so I am not sure how that can
> help universally. But your description is quite vague. Could you be more
> specific about that workload? Also do you see the same with the current
> upstream kernel as well?
I  just compare the kernel 3.10 with  kernel 4.4 in same situation.  I do not test the issue in the upstream kernel.
and check the /proc/pagetypeinfo after the system boots up.

migrate_highatomic  is always zero.,  while migrate_reserve has an pageblock that it can use for high order allocation.
Even though go back the migrate_reserve can not solve the issue. but In fact , it did relieve the oom situation.

Thanks,
zhong jiang



