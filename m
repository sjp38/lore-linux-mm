Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49107C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F338920663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:30:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="YtNTjUwe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F338920663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 908E96B0007; Mon, 24 Jun 2019 17:30:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BA5F8E0003; Mon, 24 Jun 2019 17:30:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 780A78E0002; Mon, 24 Jun 2019 17:30:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5397D6B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:30:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so18544195qtp.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:30:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=IdPYB32R1Ky5udWdlDMBAJnCn+Bo2KtPbU6CqfZba4M=;
        b=sC6Z37fD4b6JcUa00MgeRLzpjmBoinbe54q4rle8tnK6Uzq1zrrQX1LJYB99Rc/mYY
         +YuN4uS9Y2cC+Uhy5S4OHhFcJaB3O51NdsIuLvBmQjwxNVmm4gohKvWzaAIhcRThQd1U
         ieSHWSZjMtqQj5igzCJrkbAW21dGYeNRNitfueu4+yCufypinI7luxh4Gdre9cLEbqNt
         EPGz/tiQDuqS2ZQGiKwFWoVCO4zsPCR19HHtr8lvVc78XL6Y0FSDsRbcbUeTkBHnseFd
         kSahCvC13DFJnvT9pz9pOSBUZnPzV9z5Nn8B/aj8UZzWu1MF8UcPuXaT9cW8QbkbhJRl
         S1KA==
X-Gm-Message-State: APjAAAUam/NfSjOyT3L7VQGClxskCinMkN0A8srQExTTVa+dBXqX6ftc
	Cf1Aj4OdKdONYVkiSVNzLq8a7q5hgEwEqKDdR7b7sBsBIZMCR/k1XRH3QdCLSmgKeJfeHZipZDg
	bYDrKFpCQE1nIfwfCIHhHlJ7p6gqnfPBlfI1+/hF/ZTBw5hi9lquWCPjcLQHcCOgZ4g==
X-Received: by 2002:a0c:b192:: with SMTP id v18mr53061422qvd.90.1561411843083;
        Mon, 24 Jun 2019 14:30:43 -0700 (PDT)
X-Received: by 2002:a0c:b192:: with SMTP id v18mr53061367qvd.90.1561411842367;
        Mon, 24 Jun 2019 14:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561411842; cv=none;
        d=google.com; s=arc-20160816;
        b=eMs2CvQCaMMX8BG9avoGLetXTM9aazywR0YZNEjgl6dq6mk93TEzw0FflZ2epvfDF6
         +zAchlTJMVhIaRb/Le/Owygln76Jyes8QwbIwFsJuzt8WqwPQDoaSZeH1usUv/BV3JUX
         B6kDtzX7HCxlSp+7tpMmjgE4k05JjcdFbA456OMYVA3n38teQzLLzb8yY769TgDOy06M
         9B4OtVnT//SHeKhvSuuC529XsnvLpuoMIKv3ajIG8KmnXHqSfaGyQLdunRJrHimg/3cD
         ICbUvbS6fwjdNRNWyw9Hasqz5wO409mURMdz+gYstxTHzSCDFcTTqfNn51jiGJO5liDG
         fL9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=IdPYB32R1Ky5udWdlDMBAJnCn+Bo2KtPbU6CqfZba4M=;
        b=QRhjkBNfjlFcb2cTKas6lNkwa/37Cl26cP+jnnqFPpiNpbdjMXDz7n71V9Ytnn9KX4
         eXOithQkBOYzIcFy9f0YZ+KVR4lb1alNU53ZGeVdJJeDw6NGsxyYmkdndq2nDmzev/6P
         +yNkGidIAy3hfwcgjCbaBcDYEo0BHdHGn9e0WgRBh83PNYiAM1iG+Wmstx8jSuiiiWG3
         pjhSD/3gIdiBYvgL5848LxQx8PtXposPWvzJNgY4Mlx2XElHuvu1SarFeGj3OpFPMAsq
         bQbLrBhgBl4WfNqVTIcmk4qalIwE5ELMkWJarz6o9vEG+NvQEu7n60o8MSKYxSgaVeOI
         0oiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=YtNTjUwe;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4sor16817515qti.68.2019.06.24.14.30.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:30:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=YtNTjUwe;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IdPYB32R1Ky5udWdlDMBAJnCn+Bo2KtPbU6CqfZba4M=;
        b=YtNTjUwedsLsfc7DrryL4Gz7SHsyOwurki3ZAuLGi5jv3uoV1XDzNuVshE2rgNJNk7
         7B4h1/7Ftgrcz4FUW9IG5jLOzQmp+3MiTHbK1xzrjDwrPmaEvaaCsHhik+IX27Rxptfy
         hCbmTnibUCjBBtgsebBw1Yu7PyaULyPUdqE0uikoDJe1LStMwO3JfI7lG38VrHZ8Vlsf
         C8N0Y39Vin7o/umAsyJo603Fl/rEM30epk4k/3BDRXauVyd49VRXp2mTLfwCaSwo+ryL
         CCfu6apCDfSUOfIcf6TMIT6ubmfzCP3IGRY2YjyczjnEeDrzIjdliMcKaAMpp/KNc8aa
         IOzw==
X-Google-Smtp-Source: APXvYqyS6XZTOn9QKS3QHPK7KdIUEBDmjNO9cZeXeZ9E/jUJ7+RGxN37MlErmlyPXHlBJErk3AADkg==
X-Received: by 2002:ac8:1946:: with SMTP id g6mr44679856qtk.225.1561411841994;
        Mon, 24 Jun 2019 14:30:41 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id s23sm7340370qtk.31.2019.06.24.14.30.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 14:30:41 -0700 (PDT)
Message-ID: <1561411839.5154.60.camel@lca.pw>
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
From: Qian Cai <cai@lca.pw>
To: Will Deacon <will@kernel.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Catalin Marinas
 <catalin.marinas@arm.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  linux-arm-kernel@lists.infradead.org, Mike
 Kravetz <mike.kravetz@oracle.com>
Date: Mon, 24 Jun 2019 17:30:39 -0400
In-Reply-To: <1561381129.5154.55.camel@lca.pw>
References: <1560461641.5154.19.camel@lca.pw>
	 <20190614102017.GC10659@fuggles.cambridge.arm.com>
	 <1560514539.5154.20.camel@lca.pw>
	 <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
	 <EC704BC3-62FF-4DCE-8127-40279ED50D65@lca.pw>
	 <20190624093507.6m2quduiacuot3ne@willie-the-truck>
	 <1561381129.5154.55.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

So the problem is that ipcget_public() has held the semaphore "ids->rwsem" for
too long seems unnecessarily and then goes to sleep sometimes due to direct
reclaim (other times LTP hugemmap05 [1] has hugetlb_file_setup() returns
-ENOMEM),

[  788.765739][ T1315] INFO: task hugemmap05:5001 can't die for more than 122
seconds.
[  788.773512][ T1315] hugemmap05      R  running task    25600  5001      1
0x0000000d
[  788.781348][ T1315] Call trace:
[  788.784536][ T1315]  __switch_to+0x2e0/0x37c
[  788.788848][ T1315]  try_to_free_pages+0x614/0x934
[  788.793679][ T1315]  __alloc_pages_nodemask+0xe88/0x1d60
[  788.799030][ T1315]  alloc_fresh_huge_page+0x16c/0x588
[  788.804206][ T1315]  alloc_surplus_huge_page+0x9c/0x278
[  788.809468][ T1315]  hugetlb_acct_memory+0x114/0x5c4
[  788.814469][ T1315]  hugetlb_reserve_pages+0x170/0x2b0
[  788.819662][ T1315]  hugetlb_file_setup+0x26c/0x3a8
[  788.824600][ T1315]  newseg+0x220/0x63c
[  788.828490][ T1315]  ipcget+0x570/0x674
[  788.832377][ T1315]  ksys_shmget+0x90/0xc4
[  788.836525][ T1315]  __arm64_sys_shmget+0x54/0x88
[  788.841282][ T1315]  el0_svc_handler+0x19c/0x26c
[  788.845952][ T1315]  el0_svc+0x8/0xc

and then all other processes are waiting on the semaphore causes lock
contentions,

[  788.849583][ T1315] INFO: task hugemmap05:5027 blocked for more than 122
seconds.
[  788.857119][ T1315]       Tainted: G        W         5.2.0-rc6-next-20190624 
#2
[  788.864566][ T1315] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  788.873139][ T1315] hugemmap05      D26960  5027   5026 0x00000000
[  788.879395][ T1315] Call trace:
[  788.882576][ T1315]  __switch_to+0x2e0/0x37c
[  788.886901][ T1315]  __schedule+0xb74/0xf0c
[  788.891136][ T1315]  schedule+0x60/0x168
[  788.895097][ T1315]  rwsem_down_write_slowpath+0x5a0/0x8c8
[  788.900653][ T1315]  down_write+0xc0/0xc4
[  788.904715][ T1315]  ipcget+0x74/0x674
[  788.908516][ T1315]  ksys_shmget+0x90/0xc4
[  788.912664][ T1315]  __arm64_sys_shmget+0x54/0x88
[  788.917420][ T1315]  el0_svc_handler+0x19c/0x26c
[  788.922088][ T1315]  el0_svc+0x8/0xc

Ideally, it seems only ipc_findkey() and newseg() in this path needs to hold the
semaphore to protect concurrency access, so it could just be converted to a
spinlock instead.

[1] ./hugemmap05 -s -m

https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/huget
lb/hugemmap/hugemmap05.c

