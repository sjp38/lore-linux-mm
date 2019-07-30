Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38A51C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 16:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB84A206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 16:25:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="B3Z3C8i4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB84A206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D7BC8E0005; Tue, 30 Jul 2019 12:25:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 461A38E0001; Tue, 30 Jul 2019 12:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DA7B8E0005; Tue, 30 Jul 2019 12:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECD298E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:25:34 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id p193so28109180vkd.7
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:25:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:mime-version:content-transfer-encoding;
        bh=oZDd1yWJsEjy6SmgWM8sUgTAxEOgOaQewfcF4rfuJjA=;
        b=ucVjWhwJveRwoH1NXNLCifhkKDfqWKKnLJlz/cxbAGzQ1JVIUfuJXtWDcaCMOOho9Q
         KHkYo7MmF7KuTT1i7cB0V/I59aBjyudH4WqgOwBFazkx33lj+pRstDPGo8R8qAhIMmxj
         aKysPTnZHKdDn7gmXdLouO3hdgzbm8zcdyJZdWW87cDSiq83oP6CED4gSofV8JoQvC4q
         bsW9ToVbZqfFs3s7axJXnWI7jo7GR6kuJDSfwFP7pTFnhWvZHhwKkeL+/LKdIp4uwHui
         jp8frmxVRMcxB/KU/zTJtFgQm5ozwD78GE7RAoh53QV6GlMYOphzHFcx5nwVkxx66Nf2
         2vhw==
X-Gm-Message-State: APjAAAU30PO6ofsdnuWzKLUxLNpNOm2Wa6o2PYC5qs/BrzAgqiuVBs22
	kMYew2XiCx13NQszcAxUM0oENolLDqy19jc7So6gMhQnY5cz8RRSf8RsgVOg7nlejNwMYY7lh+9
	NGggMW3L4cNCqAwl1GuexaK4oxha37PQT2UdITJ2fI21BZ0Oq5MFNnqDLsTVkhiY67A==
X-Received: by 2002:ab0:1c0c:: with SMTP id a12mr31520464uaj.75.1564503934605;
        Tue, 30 Jul 2019 09:25:34 -0700 (PDT)
X-Received: by 2002:ab0:1c0c:: with SMTP id a12mr31520189uaj.75.1564503932075;
        Tue, 30 Jul 2019 09:25:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564503932; cv=none;
        d=google.com; s=arc-20160816;
        b=XlVk6hAE0N+ACanaXZbXpvXzh8LfUtxbMR4fhHZ8qzoTkk2gfjsOxk9Ub+/+xLoSlh
         bPHQ8L/Rd5tkagGZDWmqSMbDOJOsJp0ghOQRmieaS5pNvt216IsZDRtUUWBartofK8uj
         NJy7R/2za4duornxlh6D362RUlSh+rcmHccLoCwR/7orqyStIUfb32xsv0zkDBYNLtTU
         EF5JfuQYOw0vbJ7f7gCRNa9B4DO6ZyM/FNqscsoEI2otUvIrctqD/IVATh5Wsse9tUFS
         3xAxrIY2ElaOTHpcxa1nmiwVr6Ye1NKN+DeSZ7Va4Qh/GgHtgnlDDL0ojI4yMSnBHjRr
         NFCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:date:cc:to:from:subject
         :message-id:dkim-signature;
        bh=oZDd1yWJsEjy6SmgWM8sUgTAxEOgOaQewfcF4rfuJjA=;
        b=Pudx70zEgUL2QSKAToEFD1tA/U8WqOhC5XviA5nceePjsz1wh1YQ41qgIx62mw2W7D
         mb9ywc6Ha4pG5XPSQDFDQRbLM8u/uWs5n1BjuEYbgLzLpuKS5gubjqJSV7UFtHDwJ3Ia
         3nmoEEkDvzAvlz65NoqZYZklMJBc+/i2kkC52kpuuSnCjEjDxyXAh5SeAKGv2A2Aushh
         SI7eyFgco/SgzkcCVvhASs2g3Cmue/EMCtNzfXulDYMCtFgvCSdrmsjAU0qDR/yUyQUn
         Tj3qNDjKk4ztKSi88crVXKN78eMRoR5dHwgr+6wZHT/wPB4spR3EPggR8pbSKwb3T5oT
         Nl6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=B3Z3C8i4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s192sor33032597vsc.64.2019.07.30.09.25.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 09:25:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=B3Z3C8i4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=oZDd1yWJsEjy6SmgWM8sUgTAxEOgOaQewfcF4rfuJjA=;
        b=B3Z3C8i43tNHxF55ZizTTGIz7nLaNolQbwIKMTadCbP1Vlkh4Ka52VemevJlwxEEE4
         rEAlrmr5boiRK22R3FzJEtX671W5L2n0e0QJGnI5uNUqmViJcum7QUP+AY+tnz6eQZJl
         /W/UlOh03gventZsYKv5CkWAsK30QMHZ4kqlbPVEbSqBLJIikyHbePGR/FW+FEuXT6B4
         R07Y48yWN/jkwyfYGhzo9FPIvrMbn5co148VlgDquwDLSSAh+M8oH+01Efl7gh6NdoQw
         8kFnA37RyzdCZ21V3hMsNpJIgck7CaiZ8va2pgUaNISx5R+tEA/k8bwROzWaw8Cy2Obx
         T5DQ==
X-Google-Smtp-Source: APXvYqx5SGUIpXpffHH0he0v3zLcM6Jgn15LBb8jUd+GimR5s418fApmvLLiPi0yZUsmtxDfeHa/Zw==
X-Received: by 2002:a67:bc7:: with SMTP id 190mr50432068vsl.6.1564503930774;
        Tue, 30 Jul 2019 09:25:30 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 10sm26658307vkl.33.2019.07.30.09.25.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 09:25:29 -0700 (PDT)
Message-ID: <1564503928.11067.32.camel@lca.pw>
Subject: "mm: account nr_isolated_xxx in [isolate|putback]_lru_page" breaks
 OOM with swap
From: Qian Cai <cai@lca.pw>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner
	 <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Tue, 30 Jul 2019 12:25:28 -0400
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

OOM workloads with swapping is unable to recover with linux-next since next-
20190729 due to the commit "mm: account nr_isolated_xxx in
[isolate|putback]_lru_page" breaks OOM with swap" [1]

[1] https://lore.kernel.org/linux-mm/20190726023435.214162-4-minchan@kernel.org/
T/#mdcd03bcb4746f2f23e6f508c205943726aee8355

For example, LTP oom01 test case is stuck for hours, while it finishes in a few
minutes here after reverted the above commit. Sometimes, it prints those message
while hanging.

[  509.983393][  T711] INFO: task oom01:5331 blocked for more than 122 seconds.
[  509.983431][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.983447][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.983477][  T711] oom01           D24656  5331   5157 0x00040000
[  509.983513][  T711] Call Trace:
[  509.983538][  T711] [c00020037d00f880] [0000000000000008] 0x8 (unreliable)
[  509.983583][  T711] [c00020037d00fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.983615][  T711] [c00020037d00fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.983647][  T711] [c00020037d00fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.983684][  T711] [c00020037d00fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.983727][  T711] [c00020037d00fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.983758][  T711] [c00020037d00fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.983801][  T711] [c00020037d00fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.983832][  T711] INFO: task oom01:5333 blocked for more than 122 seconds.
[  509.983862][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.983887][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.983928][  T711] oom01           D26352  5333   5157 0x00040000
[  509.983964][  T711] Call Trace:
[  509.983990][  T711] [c00020089ae4f880] [c0000000015d1180]
rcu_lock_map+0x0/0x20 (unreliable)
[  509.984038][  T711] [c00020089ae4fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.984078][  T711] [c00020089ae4fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.984121][  T711] [c00020089ae4fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.984151][  T711] [c00020089ae4fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.984193][  T711] [c00020089ae4fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.984244][  T711] [c00020089ae4fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.984284][  T711] [c00020089ae4fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.984324][  T711] INFO: task oom01:5339 blocked for more than 122 seconds.
[  509.984362][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.984388][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.984429][  T711] oom01           D26352  5339   5157 0x00040000
[  509.984469][  T711] Call Trace:
[  509.984493][  T711] [c00020175cd4f880] [c00020175cd4f8d0] 0xc00020175cd4f8d0
(unreliable)
[  509.984545][  T711] [c00020175cd4fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.984586][  T711] [c00020175cd4fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.984628][  T711] [c00020175cd4fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.984678][  T711] [c00020175cd4fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.984732][  T711] [c00020175cd4fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.984751][  T711] [c00020175cd4fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.984791][  T711] [c00020175cd4fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.984840][  T711] INFO: task oom01:5341 blocked for more than 122 seconds.
[  509.984879][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.984916][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.984966][  T711] oom01           D26352  5341   5157 0x00040000
[  509.985008][  T711] Call Trace:
[  509.985032][  T711] [c000200d8aa6f880] [c000200d8aa6f8d0] 0xc000200d8aa6f8d0
(unreliable)
[  509.985074][  T711] [c000200d8aa6fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.985112][  T711] [c000200d8aa6fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.985152][  T711] [c000200d8aa6fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.985191][  T711] [c000200d8aa6fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.985234][  T711] [c000200d8aa6fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.985285][  T711] [c000200d8aa6fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.985335][  T711] [c000200d8aa6fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.985387][  T711] INFO: task oom01:5348 blocked for more than 122 seconds.
[  509.985424][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.985470][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.985522][  T711] oom01           D26352  5348   5157 0x00040000
[  509.985565][  T711] Call Trace:
[  509.985588][  T711] [c00020089a46f880] [c00020089a46f8d0] 0xc00020089a46f8d0
(unreliable)
[  509.985628][  T711] [c00020089a46fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.985669][  T711] [c00020089a46fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.985711][  T711] [c00020089a46fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.985751][  T711] [c00020089a46fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.985793][  T711] [c00020089a46fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.985836][  T711] [c00020089a46fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.985887][  T711] [c00020089a46fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.985937][  T711] INFO: task oom01:5355 blocked for more than 122 seconds.
[  509.985976][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.986012][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.986054][  T711] oom01           D26352  5355   5157 0x00040000
[  509.986092][  T711] Call Trace:
[  509.986125][  T711] [c0002011b220f880] [c0002011b220f8d0] 0xc0002011b220f8d0
(unreliable)
[  509.986157][  T711] [c0002011b220fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.986194][  T711] [c0002011b220fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.986235][  T711] [c0002011b220fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.986273][  T711] [c0002011b220fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.986315][  T711] [c0002011b220fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.986356][  T711] [c0002011b220fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.986397][  T711] [c0002011b220fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.986437][  T711] INFO: task oom01:5356 blocked for more than 122 seconds.
[  509.986474][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.986512][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.986621][  T711] oom01           D26352  5356   5157 0x00040000
[  509.986715][  T711] Call Trace:
[  509.986748][  T711] [c00020107806f880] [0000000000000008] 0x8 (unreliable)
[  509.986830][  T711] [c00020107806fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.986937][  T711] [c00020107806fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.987028][  T711] [c00020107806fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.987123][  T711] [c00020107806fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.987232][  T711] [c00020107806fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.987317][  T711] [c00020107806fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.987445][  T711] [c00020107806fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.987528][  T711] INFO: task oom01:5363 blocked for more than 122 seconds.
[  509.987626][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.987728][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.987829][  T711] oom01           D26352  5363   5157 0x00040000
[  509.987899][  T711] Call Trace:
[  509.987934][  T711] [c0002010f510f880] [c0000000015d1180]
rcu_lock_map+0x0/0x20 (unreliable)
[  509.988040][  T711] [c0002010f510fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.988162][  T711] [c0002010f510fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.988246][  T711] [c0002010f510fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.988322][  T711] [c0002010f510fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.988429][  T711] [c0002010f510fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.988528][  T711] [c0002010f510fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.988625][  T711] [c0002010f510fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.988737][  T711] INFO: task oom01:5364 blocked for more than 122 seconds.
[  509.988836][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.988894][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.988989][  T711] oom01           D26352  5364   5157 0x00040000
[  509.989097][  T711] Call Trace:
[  509.989137][  T711] [c0002017e444f880] [c0002017e444f8d0] 0xc0002017e444f8d0
(unreliable)
[  509.989248][  T711] [c0002017e444fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.989345][  T711] [c0002017e444fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.989459][  T711] [c0002017e444fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.989528][  T711] [c0002017e444fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.989652][  T711] [c0002017e444fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.989747][  T711] [c0002017e444fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.989859][  T711] [c0002017e444fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.989972][  T711] INFO: task oom01:5367 blocked for more than 122 seconds.
[  509.990074][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
[  509.990141][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  509.990221][  T711] oom01           D26352  5367   5157 0x00040000
[  509.990295][  T711] Call Trace:
[  509.990376][  T711] [c0002008d216f880] [c0002008d216f8d0] 0xc0002008d216f8d0
(unreliable)
[  509.990494][  T711] [c0002008d216fa60] [c000000000023724]
__switch_to+0x3a4/0x520
[  509.990601][  T711] [c0002008d216fad0] [c0000000008d17bc]
__schedule+0x2fc/0x950
[  509.990684][  T711] [c0002008d216fba0] [c0000000008d1e68] schedule+0x58/0x150
[  509.990755][  T711] [c0002008d216fbd0] [c0000000008d7614]
rwsem_down_read_slowpath+0x4b4/0x630
[  509.990886][  T711] [c0002008d216fc90] [c0000000008d7dfc]
down_read+0x12c/0x240
[  509.990965][  T711] [c0002008d216fd20] [c00000000005fb28]
__do_page_fault+0x6f8/0xee0
[  509.991077][  T711] [c0002008d216fe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[  509.991187][  T711] 
[  509.991187][  T711] Showing all locks held in the system:
[  509.991361][  T711] 1 lock held by khungtaskd/711:
[  509.991375][  T711]  #0: 000000006e6271c2 (rcu_read_lock){....}, at:
debug_show_all_locks+0x50/0x170
[  509.991520][  T711] 1 lock held by systemd-udevd/1612:
[  509.991577][  T711]  #0: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.991728][  T711] 1 lock held by oom01/5331:
[  509.991766][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.991876][  T711] 2 locks held by oom01/5332:
[  509.991930][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.992037][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.992174][  T711] 1 lock held by oom01/5333:
[  509.992228][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.992350][  T711] 2 locks held by oom01/5334:
[  509.992407][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.992524][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.992631][  T711] 1 lock held by oom01/5335:
[  509.992707][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.992828][  T711] 2 locks held by oom01/5336:
[  509.992890][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.992996][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.993135][  T711] 1 lock held by oom01/5337:
[  509.993202][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.993352][  T711] 2 locks held by oom01/5338:
[  509.993395][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.993519][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.993647][  T711] 1 lock held by oom01/5339:
[  509.993694][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.993800][  T711] 2 locks held by oom01/5340:
[  509.993874][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.994014][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.994157][  T711] 1 lock held by oom01/5341:
[  509.994229][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.994328][  T711] 2 locks held by oom01/5342:
[  509.994382][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.994511][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.994638][  T711] 2 locks held by oom01/5343:
[  509.994729][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.994825][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.994976][  T711] 2 locks held by oom01/5344:
[  509.995036][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.995134][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.995258][  T711] 2 locks held by oom01/5345:
[  509.995306][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.995432][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.995540][  T711] 2 locks held by oom01/5346:
[  509.995601][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.995704][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.995822][  T711] 2 locks held by oom01/5347:
[  509.995898][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.996025][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.996143][  T711] 1 lock held by oom01/5348:
[  509.996208][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.996313][  T711] 2 locks held by oom01/5349:
[  509.996369][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.996497][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.996621][  T711] 1 lock held by oom01/5350:
[  509.996675][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.996791][  T711] 2 locks held by oom01/5351:
[  509.996837][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.996946][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.997067][  T711] 1 lock held by oom01/5352:
[  509.997126][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.997258][  T711] 2 locks held by oom01/5353:
[  509.997295][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.997400][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.997533][  T711] 2 locks held by oom01/5354:
[  509.997595][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.997711][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.997837][  T711] 1 lock held by oom01/5355:
[  509.997886][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.998005][  T711] 1 lock held by oom01/5356:
[  509.998056][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.998169][  T711] 1 lock held by oom01/5357:
[  509.998221][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.998357][  T711] 2 locks held by oom01/5358:
[  509.998395][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.998507][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.998632][  T711] 2 locks held by oom01/5359:
[  509.998672][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.998805][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.998917][  T711] 2 locks held by oom01/5360:
[  509.998967][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.999069][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.999178][  T711] 2 locks held by oom01/5361:
[  509.999250][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.999373][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.999483][  T711] 2 locks held by oom01/5362:
[  509.999552][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  509.999638][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  509.999763][  T711] 1 lock held by oom01/5363:
[  509.999833][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  509.999932][  T711] 1 lock held by oom01/5364:
[  510.000003][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.000136][  T711] 2 locks held by oom01/5365:
[  510.000174][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.000289][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.000421][  T711] 1 lock held by oom01/5366:
[  510.000471][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.000593][  T711] 1 lock held by oom01/5367:
[  510.000650][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.000762][  T711] 2 locks held by oom01/5368:
[  510.000799][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.000920][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.001038][  T711] 2 locks held by oom01/5369:
[  510.001115][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.001249][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.001354][  T711] 1 lock held by oom01/5370:
[  510.001404][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.001546][  T711] 2 locks held by oom01/5371:
[  510.001579][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.001701][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.001809][  T711] 1 lock held by oom01/5372:
[  510.001876][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.001979][  T711] 2 locks held by oom01/5373:
[  510.002034][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.002148][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.002272][  T711] 1 lock held by oom01/5374:
[  510.002337][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.002473][  T711] 2 locks held by oom01/5375:
[  510.002521][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.002627][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.002755][  T711] 2 locks held by oom01/5376:
[  510.002809][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.002950][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.003064][  T711] 1 lock held by oom01/5377:
[  510.003118][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.003241][  T711] 2 locks held by oom01/5378:
[  510.003310][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.003403][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.003543][  T711] 2 locks held by oom01/5379:
[  510.003610][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.003708][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.003830][  T711] 1 lock held by oom01/5380:
[  510.003891][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.004021][  T711] 1 lock held by oom01/5381:
[  510.004071][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.004183][  T711] 2 locks held by oom01/5382:
[  510.004250][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.004369][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.004486][  T711] 2 locks held by oom01/5383:
[  510.004558][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.004692][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.004797][  T711] 1 lock held by oom01/5384:
[  510.004865][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.004962][  T711] 1 lock held by oom01/5385:
[  510.005002][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[  510.005128][  T711] 1 lock held by oom01/5386:
[  510.005203][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.005318][  T711] 2 locks held by oom01/5387:
[  510.005385][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.005490][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.005604][  T711] 2 locks held by oom01/5388:
[  510.005662][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.005798][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.005908][  T711] 2 locks held by oom01/5389:
[  510.005978][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.006093][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.006206][  T711] 2 locks held by oom01/5390:
[  510.006257][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.006380][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.006510][  T711] 1 lock held by oom01/5391:
[  510.006569][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.006686][  T711] 2 locks held by oom01/5392:
[  510.006743][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.006849][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.006985][  T711] 2 locks held by oom01/5393:
[  510.007044][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.007143][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.007256][  T711] 1 lock held by oom01/5394:
[  510.007315][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.007426][  T711] 2 locks held by oom01/5395:
[  510.007504][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.007615][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.007753][  T711] 2 locks held by oom01/5396:
[  510.007802][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.007901][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.008026][  T711] 2 locks held by oom01/5397:
[  510.008099][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.008209][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.008321][  T711] 2 locks held by oom01/5398:
[  510.008380][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.008465][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.008599][  T711] 2 locks held by oom01/5399:
[  510.008673][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.008791][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.008908][  T711] 2 locks held by oom01/5400:
[  510.008977][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.009076][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.009194][  T711] 2 locks held by oom01/5401:
[  510.009265][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.009376][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.009487][  T711] 2 locks held by oom01/5402:
[  510.009546][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.009655][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.009772][  T711] 2 locks held by oom01/5403:
[  510.009843][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.009973][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.010085][  T711] 2 locks held by oom01/5404:
[  510.010152][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.010253][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.010386][  T711] 2 locks held by oom01/5405:
[  510.010448][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.010578][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.010677][  T711] 2 locks held by oom01/5406:
[  510.010736][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.010846][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.010974][  T711] 2 locks held by oom01/5407:
[  510.011051][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.011141][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.011274][  T711] 2 locks held by oom01/5408:
[  510.011314][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.011424][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.011554][  T711] 2 locks held by oom01/5409:
[  510.011617][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.011745][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.011851][  T711] 2 locks held by oom01/5410:
[  510.011902][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.012030][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.012150][  T711] 2 locks held by oom01/5411:
[  510.012225][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.012345][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.012465][  T711] 2 locks held by oom01/5412:
[  510.012505][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.012617][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.012748][  T711] 1 lock held by oom01/5413:
[  510.012817][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.012928][  T711] 2 locks held by oom01/5414:
[  510.012974][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.013088][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.013233][  T711] 2 locks held by oom01/5415:
[  510.013301][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.013422][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.013535][  T711] 2 locks held by oom01/5416:
[  510.013584][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.013700][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.013809][  T711] 2 locks held by oom01/5417:
[  510.013875][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.013987][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.014110][  T711] 2 locks held by oom01/5418:
[  510.014172][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.014271][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.014409][  T711] 2 locks held by oom01/5419:
[  510.014462][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.014591][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.014696][  T711] 2 locks held by oom01/5420:
[  510.014757][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.014880][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.014997][  T711] 2 locks held by oom01/5421:
[  510.015055][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.015189][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.015303][  T711] 2 locks held by oom01/5422:
[  510.015371][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.015514][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.015626][  T711] 1 lock held by oom01/5423:
[  510.015682][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.015808][  T711] 2 locks held by oom01/5424:
[  510.015857][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.015979][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.016073][  T711] 2 locks held by oom01/5425:
[  510.016149][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.016253][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.016388][  T711] 2 locks held by oom01/5426:
[  510.016435][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.016556][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.016674][  T711] 2 locks held by oom01/5427:
[  510.016733][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.016870][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.016983][  T711] 2 locks held by oom01/5428:
[  510.017034][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.017158][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.017266][  T711] 2 locks held by oom01/5429:
[  510.017346][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.017461][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.017586][  T711] 1 lock held by oom01/5430:
[  510.017633][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.017743][  T711] 2 locks held by oom01/5431:
[  510.017779][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.017906][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.018042][  T711] 2 locks held by oom01/5432:
[  510.018102][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.018216][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.018353][  T711] 2 locks held by oom01/5433:
[  510.018393][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.018503][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.018633][  T711] 2 locks held by oom01/5434:
[  510.018695][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.018800][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.018918][  T711] 2 locks held by oom01/5435:
[  510.018956][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.019083][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.019203][  T711] 2 locks held by oom01/5436:
[  510.019282][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.019383][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.019507][  T711] 2 locks held by oom01/5437:
[  510.019552][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.019674][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.019811][  T711] 2 locks held by oom01/5438:
[  510.019874][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.019990][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.020109][  T711] 1 lock held by oom01/5439:
[  510.020158][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.020267][  T711] 2 locks held by oom01/5440:
[  510.020321][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.020442][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.020558][  T711] 2 locks held by oom01/5441:
[  510.020613][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.020728][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.020838][  T711] 1 lock held by oom01/5442:
[  510.020909][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.021043][  T711] 2 locks held by oom01/5443:
[  510.021107][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.021217][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.021321][  T711] 2 locks held by oom01/5444:
[  510.021383][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.021521][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.021632][  T711] 2 locks held by oom01/5445:
[  510.021697][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.021804][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.021905][  T711] 2 locks held by oom01/5446:
[  510.021977][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.022087][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.022225][  T711] 2 locks held by oom01/5447:
[  510.022279][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.022379][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.022504][  T711] 2 locks held by oom01/5448:
[  510.022574][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.022697][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.022825][  T711] 2 locks held by oom01/5449:
[  510.022866][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.022975][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.023085][  T711] 2 locks held by oom01/5450:
[  510.023164][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.023289][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.023408][  T711] 2 locks held by oom01/5451:
[  510.023471][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.023565][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.023696][  T711] 2 locks held by oom01/5452:
[  510.023766][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.023880][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.024007][  T711] 2 locks held by oom01/5453:
[  510.024074][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.024203][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.024284][  T711] 2 locks held by oom01/5454:
[  510.024368][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.024472][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.024593][  T711] 2 locks held by oom01/5455:
[  510.024647][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.024772][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.024877][  T711] 2 locks held by oom01/5456:
[  510.024925][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x188/0xee0
[  510.025034][  T711]  #1: 000000009cc1462e (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[  510.025150][  T711] 1 lock held by oom01/5457:
[  510.025197][  T711]  #0: 00000000cd010082 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6f8/0xee0
[  510.025332][  T711] 
[  510.025352][  T711] =============================================
[  510.025352][  T711] 


