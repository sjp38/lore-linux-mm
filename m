Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B69C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90E6E21872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:45:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90E6E21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=free.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B08E8E0027; Thu,  7 Feb 2019 05:45:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25F938E0002; Thu,  7 Feb 2019 05:45:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1009F8E0027; Thu,  7 Feb 2019 05:45:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A70808E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 05:45:31 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f202so1957228wme.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 02:45:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=d2GC7LQOWX7qPaJ5RlJJhIoAMgPa5JZgpdhwwJKLYMw=;
        b=SGvWilBgyj+gRcB0O9++a3y694tcFu+GyP38Fm813vy55GgRzhAb+vl17PbTlZC0x1
         wMpe9Xbc0bSqQZRKQl/L9i+TVKdoBMx62PdXWJfrFYa5LdKzBKvE7WUANikTO2n40ly8
         20fvDqOlXg2MVFpif0PBqvKQ0VRIcytUb60QmSeyC29VC58Bi9Q4ED1+McPfrXc7mt5c
         vlueZdb6LRtH5WRpPycU6I4PZLNpr1+xypjDqD9q171yxkLWf6lGE4EZqrnOAO1hrzb5
         0vHNVuTTDTjHu2svARiwotljtmyLlWbHU5t82Tk532L1yhoml1kwPGClXmjPsn20cz70
         I1JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
X-Gm-Message-State: AHQUAua/uAR1v7SbCt7Xpe3qTkAsg0aZ6hdTsfvMmLzD0gtyBiVODws+
	bq842fIbIaHhpULvDY8TDWcS+ZlGYdTJ9hbBFbvNfQFRELDFh0IUMhxLUEnsZWgvmeQDRTNt5OB
	O4D9aKVPq79OuoN0zGBiSZ/rbJcl+w3SbC4FZXej0QxD1+HTMJmNNjVfcXvSEfJh/qg==
X-Received: by 2002:adf:e746:: with SMTP id c6mr12181073wrn.218.1549536331158;
        Thu, 07 Feb 2019 02:45:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibmz40JXE4H31ab8OYJI3GueXEFZCgYxvwYLOdaUbV4Gvm39WaoBUbLK4YhjFlY1VJwRByq
X-Received: by 2002:adf:e746:: with SMTP id c6mr12181001wrn.218.1549536330041;
        Thu, 07 Feb 2019 02:45:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549536330; cv=none;
        d=google.com; s=arc-20160816;
        b=GNFpoW5P1zJmacvR490dR9RwgogHhMoSsVVkho+eXvarO+fV1TPl3FM06N6HTvakVE
         QDoRmFh5+TpCVM9VPRTnr+IsTmb+aVRphuS5pEYz+qiJ29DjSYBJKs+c6oqZfQ7Rluty
         4gamw8LNTcZooz+4Mo6BRqBEBMEXYEvNtF6P6WAAORZAl3HswyB0umXzqLBUyGXi+HDA
         w/kl6iSsocovsiN+7WlSXSFUnDmAc5WnDhBMavA6MlzigqQb+HDDK7kCpnp3sFB0QNHK
         t440mHt0z02UV1sj/X6eoNqmcQ5vMknuDYHwisRqsk5XYDu6r5CcjX6KCD9mcYbtptd8
         SpiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=d2GC7LQOWX7qPaJ5RlJJhIoAMgPa5JZgpdhwwJKLYMw=;
        b=ZP/60Ul4c3gV4iI7/oKWNp3zykWVI+QJzB4CAeImINTM8bzcqQudPQFqENtCyh4G8w
         qPLt2ZOiHOU8mRaEDdDGXFIIbLTqXbfL54X4B8xgcysdLHcpaszFO3jKek+TxGkWEVkq
         RsW217O9gPfXAS2WVb2CFbNwgyv4+PjncySD55gG2WqFUW3EKOK3ptwRloTfu/ZM4hw7
         0OhRbzIonZ5znLyWR/fYnyrMcOet7GyoleVkvxYs91DjBVasB2IW8RzhB1BSzI9ynh/C
         2jH24JnSlkphANK14Y3OqJYLJIqncG75Cuwc7z8TViRZdKjfnRyTvM/x2ohgjZw15m2o
         8T3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from smtp3-g21.free.fr (smtp3-g21.free.fr. [212.27.42.3])
        by mx.google.com with ESMTPS id l185si13637300wml.21.2019.02.07.02.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 02:45:30 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) client-ip=212.27.42.3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from [192.168.108.68] (unknown [213.36.7.13])
	(Authenticated sender: marc.w.gonzalez)
	by smtp3-g21.free.fr (Postfix) with ESMTPSA id 89E2D13F8CD;
	Thu,  7 Feb 2019 11:44:34 +0100 (CET)
Subject: Re: dd hangs when reading large partitions
From: Marc Gonzalez <marc.w.gonzalez@free.fr>
To: linux-mm <linux-mm@kvack.org>, linux-block <linux-block@vger.kernel.org>
Cc: Jianchao Wang <jianchao.w.wang@oracle.com>,
 Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
 fsdevel <linux-fsdevel@vger.kernel.org>, SCSI <linux-scsi@vger.kernel.org>,
 Joao Pinto <jpinto@synopsys.com>, Jeffrey Hugo <jhugo@codeaurora.org>,
 Evan Green <evgreen@chromium.org>, Matthias Kaehlcke <mka@chromium.org>,
 Douglas Anderson <dianders@chromium.org>, Stephen Boyd
 <swboyd@chromium.org>, Tomas Winkler <tomas.winkler@intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Alim Akhtar <alim.akhtar@samsung.com>, Avri Altman <avri.altman@wdc.com>,
 Bart Van Assche <bart.vanassche@wdc.com>,
 Martin Petersen <martin.petersen@oracle.com>,
 Bjorn Andersson <bjorn.andersson@linaro.org>, Ming Lei
 <ming.lei@redhat.com>, Omar Sandoval <osandov@fb.com>,
 Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>
References: <f792574c-e083-b218-13b4-c89be6566015@free.fr>
 <398a6e83-d482-6e72-5806-6d5bbe8bfdd9@oracle.com>
 <ef734b94-e72b-771f-350b-08d8054a58f3@kernel.dk>
 <20190119095601.GA7440@infradead.org>
 <07b2df5d-e1fe-9523-7c11-f3058a966f8a@free.fr>
 <985b340c-623f-6df2-66bd-d9f4003189ea@free.fr>
 <b3910158-83d6-21fe-1606-33e88912404a@oracle.com>
 <d082bdee-62e5-d470-b63b-196c0fe3b9fb@free.fr>
 <5132e41b-cb1a-5b81-4a72-37d0f9ea4bb9@oracle.com>
 <7bd8b010-bf0c-ad64-f927-2d2187a18d0b@free.fr>
 <0cfe1ed2-41e1-66a4-8d98-ebc0d9645d21@free.fr>
Message-ID: <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
Date: Thu, 7 Feb 2019 11:44:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <0cfe1ed2-41e1-66a4-8d98-ebc0d9645d21@free.fr>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+ linux-mm

Summarizing the issue for linux-mm readers:

If I read data from a storage device larger than my system's RAM, the system freezes
once dd has read more data than available RAM.

# dd if=/dev/sde of=/dev/null bs=1M & while true; do echo m > /proc/sysrq-trigger; echo; echo; sleep 1; done
https://pastebin.ubuntu.com/p/HXzdqDZH4W/

A few seconds before the system hangs, Mem-Info shows:

[   90.986784] Node 0 active_anon:7060kB inactive_anon:13644kB active_file:0kB inactive_file:3797500kB [...]

=> 3797500kB is basically all of RAM.

I tried to locate where "inactive_file" was being increased from, and saw two signatures:

[  255.606019] __mod_node_page_state | __pagevec_lru_add_fn | pagevec_lru_move_fn | __lru_cache_add | lru_cache_add | add_to_page_cache_lru | mpage_readpages | blkdev_readpages | read_pages | __do_page_cache_readahead | ondemand_readahead | page_cache_sync_readahead

[  255.637238] __mod_node_page_state | __pagevec_lru_add_fn | pagevec_lru_move_fn | __lru_cache_add | lru_cache_add | lru_cache_add_active_or_unevictable | __handle_mm_fault | handle_mm_fault | do_page_fault | do_translation_fault | do_mem_abort | el1_da

Are these expected?

NB: the system does not hang if I specify 'iflag=direct' to dd.

According to the RCU watchdog:

[  108.466240] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
[  108.466420] rcu:     1-...0: (130 ticks this GP) idle=79e/1/0x4000000000000000 softirq=2393/2523 fqs=2626 
[  108.471436] rcu:     (detected by 4, t=5252 jiffies, g=133, q=85)
[  108.480605] Task dump for CPU 1:
[  108.486483] kworker/1:1H    R  running task        0   680      2 0x0000002a
[  108.489977] Workqueue: kblockd blk_mq_run_work_fn
[  108.496908] Call trace:
[  108.501513]  __switch_to+0x174/0x1e0
[  108.503757]  blk_mq_run_work_fn+0x28/0x40
[  108.507589]  process_one_work+0x208/0x480
[  108.511486]  worker_thread+0x48/0x460
[  108.515480]  kthread+0x124/0x130
[  108.519123]  ret_from_fork+0x10/0x1c

Can anyone shed some light on what's going on?

Regards.

