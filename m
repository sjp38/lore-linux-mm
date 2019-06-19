Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFDC3C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:37:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EC6421670
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:37:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EC6421670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFB386B0005; Wed, 19 Jun 2019 09:37:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BABFD8E0002; Wed, 19 Jun 2019 09:37:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A74728E0001; Wed, 19 Jun 2019 09:37:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71DC16B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:37:30 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e7so9874927plt.13
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:37:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:list-id:archived-at
         :list-archive:list-post:content-transfer-encoding;
        bh=+KfcEURYvziluw1xLg+9T3liUQ7/p8mUMsNmneX3AkM=;
        b=YtbSkC+RpkeZgnv34jibFELF3xlVDsBQpiIK2vgVQHfYwYCLgs50P2rSdrxoJygecq
         +NzgcmAvKsu3IbrvAkudqiqXVo3pJ8m4VK33JHOWO8jfKzHp1amkMnmTY6BurflXq5k0
         EujzWhOzjd9LTLBSSypGVJT6vehI+17WzAM8FcIBCm3XxFUGfLshtrePiRoCpl9WNV5a
         a7TS/G/uTYU5Zn7Vzr92z8pRt/qYR8mmuj4LChH7vp9nB+spuMwif11/7IqdMh4dH0Ug
         UFNTnyJYt93Q7QtyTZtMCcNK4UWjpgEar8yqGFces4zWiVIfy/d+wMmu0RClauLEv4xt
         VLPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAWScpY3XZLFZDTqWBTQlTUPJPpeehr48eFYUvz6iuLHn6IQNUcG
	tiXvadLpbKa/+rR+OrZg9m699tNXnz7VkcC8M2/loyiapGshTYW3p6bOFrPRo34QG5PqbrfpvmL
	Q6oEU49JIUL3+pteZxAoCXjvFZep+HyUJs0cj5sfXx9ft/D76OdYDmtYuP+ZRK7xAXA==
X-Received: by 2002:a17:902:294a:: with SMTP id g68mr121946955plb.169.1560951450044;
        Wed, 19 Jun 2019 06:37:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlboynHrQPjaE5VttM11VzmAUfrWH56j9CYY/JBIOoOUGuc/i0czB2EzW/CSiZ8nL1So6k
X-Received: by 2002:a17:902:294a:: with SMTP id g68mr121946878plb.169.1560951449022;
        Wed, 19 Jun 2019 06:37:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560951449; cv=none;
        d=google.com; s=arc-20160816;
        b=vn6gi5m4J0u6Ib5n4ianKxtXna+PIWiEzsEm5YA/JmesouunltdiFdMulZ4tLyfASt
         a4xyDIWkOltyHigGvsq07VJz92L7NrjNGYRYTPLib5cGVtn9iLuXasGGJHE7rIg/brpG
         6jz491wiBkx5g5VPI76g0PkG5hyxYvUQMST3bnOpojWbwstnC51HTAJ5kxJeomY0Ukp6
         YMOwsLo96ScLT0PgnbWRJKte/RIWIDu8FAzRwUwWxcEDc4lndc8h9AS25MTYXN3xnWpo
         HQU0z1sFOM4LmKBLysNF9vKUbhGxREBJ9BP+OBzTXz2NywQC6OUD6GJPG6VaQvwtVQAn
         z0TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:mime-version:message-id:date:subject:cc:to:from;
        bh=+KfcEURYvziluw1xLg+9T3liUQ7/p8mUMsNmneX3AkM=;
        b=SQwTE7V4CJfEKIfWoamYh72rDgiBSeWttZKDRxAHYVXZy0qZDum1UZaQgHU8f6Cery
         2FiczxMRzsr/2rItF0TT6a6KxrCy5gM0wPEOI/CLtBcnW07s+ECwMLFtTKHaL9TRRe1D
         jiLh27s1Gw57ex9RxwIViqeCdcjTudAId93UawTS597tixQbqc+HKWw+U3F/r2FFLvEN
         zVXMd91YXnsM7MJjojoCJwzjtEtmDu3bYMNuGCLVSQfuSy7wd2YNzhh9a3W9mHMkpTU6
         ZXUV5//PR8QcItpYiR1E6gQiNIZbSXdNrZPCz+BId5rLq9SPf8I0Sn1JDfqAc+Prr/R0
         CgaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn. [202.108.3.167])
        by mx.google.com with SMTP id z21si3182517pgf.268.2019.06.19.06.37.28
        for <linux-mm@kvack.org>;
        Wed, 19 Jun 2019 06:37:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) client-ip=202.108.3.167;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.4.32])
	by sina.com with ESMTP
	id 5D0A3A9500004E41; Wed, 19 Jun 2019 21:37:27 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 292968395451
From: Hillf Danton <hdanton@sina.com>
To: Qian Cai <cai@lca.pw>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Roman Gushchin <guro@fb.com>
Subject: Re: "mm: reparent slab memory on cgroup removal" series triggers SLUB_DEBUG errors
Date: Wed, 19 Jun 2019 21:37:15 +0800
Message-Id: <20190619133715.12112-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/65CAEF0C-F2A3-4337-BAFB-895D7B470624@lca.pw/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello

On Tue, 18 Jun 2019 14:43:05 -0700 (PDT) Qian Cai wrote:
>
> [1] https://lore.kernel.org/lkml/20190611231813.3148843-1-guro@fb.com/
>
> [  151.773224][ T1650] BUG kmem_cache (Tainted: G    B   W        ): Poison overwritten
> [  151.780969][ T1650] -----------------------------------------------------------------------------
> [  151.780969][ T1650]
> [  151.792016][ T1650] INFO: 0x000000001fd6fdef-0x0000000007f6bb36. First byte 0x0 instead of 0x6b
> [  151.800726][ T1650] INFO: Allocated in create_cache+0x6c/0x1bc age$301 cpu— pid44
> [  151.808821][ T1650] 	kmem_cache_alloc+0x514/0x568
> [  151.813527][ T1650] 	create_cache+0x6c/0x1bc
> [  151.817800][ T1650] 	memcg_create_kmem_cache+0xfc/0x11c
> [  151.823028][ T1650] 	memcg_kmem_cache_create_func+0x40/0x170
> [  151.828691][ T1650] 	process_one_work+0x4e0/0xa54
> [  151.833398][ T1650] 	worker_thread+0x498/0x650
> [  151.837843][ T1650] 	kthread+0x1b8/0x1d4
> [  151.841770][ T1650] 	ret_from_fork+0x10/0x18
> [  151.846046][ T1650] INFO: Freed in slab_kmem_cache_release+0x3c/0x48 age#341 cpu( pid80
> [  151.854659][ T1650] 	slab_kmem_cache_release+0x3c/0x48
> [  151.859799][ T1650] 	kmem_cache_release+0x1c/0x28
> [  151.864507][ T1650] 	kobject_cleanup+0x134/0x288
> [  151.869127][ T1650] 	kobject_put+0x5c/0x68
> [  151.873226][ T1650] 	sysfs_slab_release+0x2c/0x38
> [  151.877931][ T1650] 	shutdown_cache+0x198/0x23c
> [  151.882464][ T1650] 	kmemcg_cache_shutdown_fn+0x1c/0x34
> [  151.887691][ T1650] 	kmemcg_workfn+0x44/0x68
> [  151.891963][ T1650] 	process_one_work+0x4e0/0xa54
> [  151.896668][ T1650] 	worker_thread+0x498/0x650
> [  151.901113][ T1650] 	kthread+0x1b8/0x1d4
> [  151.905037][ T1650] 	ret_from_fork+0x10/0x18
> [  151.909324][ T1650] INFO: Slab 0x00000000406d65a6 objectsd usedd fp=0x000000004d988e71 flags=0x7ffffffc000200
> [  151.919596][ T1650] INFO: Object 0x0000000040f4b79e @offset420325124116637824 fp=0x00000000e038adbf
> [  151.919596][ T1650]
> [  151.931079][ T1650] Redzone 00000000fc4c04f0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  151.941168][ T1650] Redzone 000000009a25c019: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  151.951256][ T1650] Redzone 000000000b05c7cc: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  151.961345][ T1650] Redzone 00000000a08ae38b: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  151.971433][ T1650] Redzone 00000000e0eccd41: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  151.981520][ T1650] Redzone 0000000016ee2661: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  151.991608][ T1650] Redzone 000000009364e729: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  152.001695][ T1650] Redzone 00000000f2202456: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................
> [  152.011784][ T1650] Object 0000000040f4b79e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.021783][ T1650] Object 000000002df21fec: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.031779][ T1650] Object 0000000041cf0887: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.041775][ T1650] Object 00000000bfb91e8f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.051770][ T1650] Object 00000000da315b1c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.061765][ T1650] Object 00000000b362de78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.071761][ T1650] Object 00000000ad4f72bf: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.081756][ T1650] Object 00000000aa32d346: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.091751][ T1650] Object 00000000ad1cf22c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.101746][ T1650] Object 000000001cee47e4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.111741][ T1650] Object 00000000418720ed: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.121736][ T1650] Object 00000000dee1c3f2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.131731][ T1650] Object 00000000a23397c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.141727][ T1650] Object 000000002ed01641: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.151721][ T1650] Object 00000000915ec720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.161716][ T1650] Object 00000000915988c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.171711][ T1650] Object 000000004a0cc60f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.181707][ T1650] Object 0000000054a294c9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.191701][ T1650] Object 0000000054f61682: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.201697][ T1650] Object 0000000018d04328: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.211692][ T1650] Object 00000000703cf2c7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.221687][ T1650] Object 000000004d3ac5d5: 6b 6b 6b 6b 6b 6b 6b 6b 00 00 00 00 00 00 00 00  kkkkkkkk........
> [  152.231682][ T1650] Object 00000000726ce587: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.241676][ T1650] Object 00000000c709b64e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.251672][ T1650] Object 0000000044d6a5c6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.261667][ T1650] Object 000000009c76a6a2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.271662][ T1650] Object 0000000033d01d12: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.281657][ T1650] Object 00000000c50ff26f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.291652][ T1650] Object 00000000ebc3aaae: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.301647][ T1650] Object 00000000a2072fe3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> [  152.311641][ T1650] Object 000000003d5911a3: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
> [  152.320942][ T1650] Redzone 000000009a2feac1: bb bb bb bb bb bb bb bb                          ........
> [  152.330330][ T1650] Padding 00000000c1b3cb8b: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [  152.340412][ T1650] Padding 000000003715421a: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [  152.350493][ T1650] Padding 0000000066b51ba7: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [  152.360575][ T1650] Padding 00000000ca240306: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [  152.370657][ T1650] Padding 0000000014a2af5d: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> [  152.380048][ T1650] CPU: 82 PID: 1650 Comm: kworker/82:1 Tainted: G    B   W         5.2.0-rc5-next-20190617 #18
> [  152.390216][ T1650] Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
> [  152.400741][ T1650] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  152.407786][ T1650] Call trace:
> [  152.410926][ T1650]  dump_backtrace+0x0/0x268
> [  152.415280][ T1650]  show_stack+0x20/0x2c
> [  152.419287][ T1650]  dump_stack+0xb4/0x108
> [  152.423384][ T1650]  print_trailer+0x274/0x298
> [  152.427825][ T1650]  check_bytes_and_report+0xc4/0x118
> [  152.432959][ T1650]  check_object+0x2fc/0x36c
> [  152.437312][ T1650]  alloc_debug_processing+0x154/0x240
> [  152.442532][ T1650]  ___slab_alloc+0x710/0xa68
> [  152.446972][ T1650]  kmem_cache_alloc+0x514/0x568
> [  152.451672][ T1650]  create_cache+0x6c/0x1bc
> [  152.455938][ T1650]  memcg_create_kmem_cache+0xfc/0x11c
> [  152.461158][ T1650]  memcg_kmem_cache_create_func+0x40/0x170
> [  152.466814][ T1650]  process_one_work+0x4e0/0xa54
> [  152.471515][ T1650]  worker_thread+0x498/0x650
> [  152.475953][ T1650]  kthread+0x1b8/0x1d4
> [  152.479872][ T1650]  ret_from_fork+0x10/0x18
> [  152.484139][ T1650] FIX kmem_cache: Restoring 0x000000001fd6fdef-0x0000000007f6bb36=0x6b
> [  152.484139][ T1650]
> [  152.494395][ T1650] FIX kmem_cache: Marking all objects used

Perhaps you can try with commit 94b655a10aaf ("mm: memcg/slab: don't check the
dying flag on kmem_cache creation") picked out.

Hillf

