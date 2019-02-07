Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0456C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:57:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9823A21872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:57:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9823A21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=free.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A3828E004E; Thu,  7 Feb 2019 11:57:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4527D8E0002; Thu,  7 Feb 2019 11:57:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36B638E004E; Thu,  7 Feb 2019 11:57:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5D758E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:57:25 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id c2so170914wrp.11
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:57:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=X/CsUjrkucxUJed7O3ivtdhWUz+4l4dl/E05gWJr/WM=;
        b=YFeMYWI6BWZQgftQTyoaAzEqO8JCvX3O04pJa4BRswGlXgjqrtCoG51aY7xHUQfBU2
         Ni4NW7bcInXkqxn+qXhJhIdKDU66IuiF2SZdogq/NJwL9zk+GeD0l9+pFWA6eGmeNtOy
         WOPSHubbGMvsDmrnZDEBDlb2qxEUNMLyM4JbbP25yec5KebQcDk0qxYLMqaCrZjV3/cy
         0lM3SDWM604K9w/BYS1Zu3XW0hTVFaKlXiJDrESd4wEsLIyJ/MPKdXr33GcjDQ8zfB59
         /NJWKr+vKJC1knP7ObTG5cvCC7i4JWFtei4YeLvmuUrWUVIS2djEv5Jmr7VjWVob94jA
         WqYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
X-Gm-Message-State: AHQUAuZkhbA8dlrRItNkRgVJc/dMXxOQGNypJP0I05/ROsfMvv5jcWd+
	9T0zXyPrwi98hYdDCszmajOHW+eIXAAIDFaxgY7CY5BpTaaUELN3e990d2Dil0Zsw4MVGlxhnru
	R9YYxi5lRlIgqpkDs8EYUAVx8eSJHKun1QyUIbRUVuUFjXs+KESo9cAv6f2eStc3Siw==
X-Received: by 2002:a5d:474f:: with SMTP id o15mr4570745wrs.70.1549558645377;
        Thu, 07 Feb 2019 08:57:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbzhxElt8Ti2xACSMW0hncGqGkPIUkh519fWIqKzBbvoI22Fyydp7KEEPu98oaZTFlJUsZ0
X-Received: by 2002:a5d:474f:: with SMTP id o15mr4570673wrs.70.1549558644126;
        Thu, 07 Feb 2019 08:57:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558644; cv=none;
        d=google.com; s=arc-20160816;
        b=NN76uCtQIVJ72KbymwM1/e6Abw9a4VhrqJPbDJhHpNJXsxb08+wb0NlM8u1wWRuOGa
         DoK35HTzU2Kc/cie615sMWSr6Qv8f3bZujoVfH9JaekQGJJ3NjeY8SGSvMhmTLoFICCD
         GpwejR6k512W90cBra2oUsgI6M/WdezlEOpTuunruRsG+u3gpAN81350JHc9OaZ4DKTP
         HMZV3JgzhLdvHiLQnWMaJLJ0KoW2h/aSD1Eae25HV7MXxFtiFQeRJsVmnd631aiWl/0+
         GC6AamcwM/L1KBzHZmmbIFROOpEdd78jQC0JZyai/Z+APLx0xLLgCKVpL4P8WGL7/UA5
         HMlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=X/CsUjrkucxUJed7O3ivtdhWUz+4l4dl/E05gWJr/WM=;
        b=ozKKlZAgE/AMLiadxLxuOjD2zRtkAziC3Hd0oSNR9qiKj0Ohd5DSD6C2PpW6xZ4yMI
         rZrv56sKckMyqMkrDrNyVgEt9c1Cu/fRDkttYS6xctCEDpYO/aogLfdpWX7uSoHKPMLa
         Sy4JdQCKdhRSn4axOCcK0t/to9ulEDogVoP17aS/wP22Nf3zCmwSk4TUDrcsAI4X+luz
         DgpSxILZ9DGTZkvt/uY9fAyI3puyDvBKNNEC5jHRAIUeZCpYDtEUNJE7ZZ3Kyu8jMSL8
         haHPolL6h3DOEbzKFNeULUcLxr/i0XaaA4KxEcYtGLm/h8TmI+ODA3pTgdihHLupJRo4
         +DwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from smtp3-g21.free.fr (smtp3-g21.free.fr. [212.27.42.3])
        by mx.google.com with ESMTPS id h92si513908wrh.3.2019.02.07.08.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:57:24 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) client-ip=212.27.42.3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from [192.168.108.68] (unknown [213.36.7.13])
	(Authenticated sender: marc.w.gonzalez)
	by smtp3-g21.free.fr (Postfix) with ESMTPSA id 5B7A513F84C;
	Thu,  7 Feb 2019 17:56:29 +0100 (CET)
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
 <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
Message-ID: <27165898-88c3-ab42-c6c9-dd52bf0a41c8@free.fr>
Date: Thu, 7 Feb 2019 17:56:29 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/02/2019 11:44, Marc Gonzalez wrote:

> + linux-mm
> 
> Summarizing the issue for linux-mm readers:
> 
> If I read data from a storage device larger than my system's RAM, the system freezes
> once dd has read more data than available RAM.
> 
> # dd if=/dev/sde of=/dev/null bs=1M & while true; do echo m > /proc/sysrq-trigger; echo; echo; sleep 1; done
> https://pastebin.ubuntu.com/p/HXzdqDZH4W/
> 
> A few seconds before the system hangs, Mem-Info shows:
> 
> [   90.986784] Node 0 active_anon:7060kB inactive_anon:13644kB active_file:0kB inactive_file:3797500kB [...]
> 
> => 3797500kB is basically all of RAM.
> 
> I tried to locate where "inactive_file" was being increased from, and saw two signatures:
> 
> [  255.606019] __mod_node_page_state | __pagevec_lru_add_fn | pagevec_lru_move_fn | __lru_cache_add | lru_cache_add | add_to_page_cache_lru | mpage_readpages | blkdev_readpages | read_pages | __do_page_cache_readahead | ondemand_readahead | page_cache_sync_readahead
> 
> [  255.637238] __mod_node_page_state | __pagevec_lru_add_fn | pagevec_lru_move_fn | __lru_cache_add | lru_cache_add | lru_cache_add_active_or_unevictable | __handle_mm_fault | handle_mm_fault | do_page_fault | do_translation_fault | do_mem_abort | el1_da
> 
> Are these expected?
> 
> NB: the system does not hang if I specify 'iflag=direct' to dd.
> 
> According to the RCU watchdog:
> 
> [  108.466240] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
> [  108.466420] rcu:     1-...0: (130 ticks this GP) idle=79e/1/0x4000000000000000 softirq=2393/2523 fqs=2626 
> [  108.471436] rcu:     (detected by 4, t=5252 jiffies, g=133, q=85)
> [  108.480605] Task dump for CPU 1:
> [  108.486483] kworker/1:1H    R  running task        0   680      2 0x0000002a
> [  108.489977] Workqueue: kblockd blk_mq_run_work_fn
> [  108.496908] Call trace:
> [  108.501513]  __switch_to+0x174/0x1e0
> [  108.503757]  blk_mq_run_work_fn+0x28/0x40
> [  108.507589]  process_one_work+0x208/0x480
> [  108.511486]  worker_thread+0x48/0x460
> [  108.515480]  kthread+0x124/0x130
> [  108.519123]  ret_from_fork+0x10/0x1c
> 
> Can anyone shed some light on what's going on?

Saw a slightly different report from another test run:
https://pastebin.ubuntu.com/p/jCywbKgRCq/

[  340.689764] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
[  340.689992] rcu:     1-...0: (8548 ticks this GP) idle=c6e/1/0x4000000000000000 softirq=82/82 fqs=6 
[  340.694977] rcu:     (detected by 5, t=5430 jiffies, g=-719, q=16)
[  340.703803] Task dump for CPU 1:
[  340.709507] dd              R  running task        0   675    673 0x00000002
[  340.713018] Call trace:
[  340.720059]  __switch_to+0x174/0x1e0
[  340.722192]  0xffffffc0f6dc9600

[  352.689742] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 33s!
[  352.689910] Showing busy workqueues and worker pools:
[  352.696743] workqueue mm_percpu_wq: flags=0x8
[  352.701753]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  352.706099]     pending: vmstat_update

[  384.693730] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 65s!
[  384.693815] Showing busy workqueues and worker pools:
[  384.700577] workqueue events: flags=0x0
[  384.705699]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  384.709351]     pending: vmstat_shepherd
[  384.715587] workqueue mm_percpu_wq: flags=0x8
[  384.719495]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  384.723754]     pending: vmstat_update

