Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08CC7C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:31:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B685A217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jaJ2fkwH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B685A217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5169A6B0003; Tue, 23 Apr 2019 11:31:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C66F6B0005; Tue, 23 Apr 2019 11:31:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B8C46B0007; Tue, 23 Apr 2019 11:31:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 191526B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:31:00 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p1so12681509ywm.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:31:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=yEsJunfUbaZmio+edIZHR7uNumWd1MHNzVqBngWscks=;
        b=DafSfTCbbpbqYE4A8Dr4KDIHROJuikfMSnt7moKZ9wj49Gp3VaiTpYbhJFjISTkoGM
         AZ9kxyNwc/OpIK6uxIpj4PTs+PdbBTI4L3HaGoVxFNmbBhrW+9GT6zE/yzYTrUk2njX7
         k8Td7LemrO/WA6tEUj0wAo/IqHPPWqr0Aa+VezakLxempiMYrLtOar+Trcc7LryqQZw8
         52ABnPE2XKFQnkah4De8bSp6cb6DyJoCR7hp/Bq+8BmhsndCmByp/C0EJpqMc0hb9B4W
         j4cBz8DoXJ+HmmR4tgQ1Og5PxfQzVOay5FIegnvLJaHlf7Vbn72QD+HTIjVlOSF5hCa1
         vJhw==
X-Gm-Message-State: APjAAAUkEFK4VsdpG/BPOWnFS9bYE8pkW3Dm6Q3TnpZ+2QlmZDst5acL
	oCzoN9lbZNkFiDiBDWTz9lQ99FxjhUidBVT2pYWb+k/mp+ZACpJH5GdEpUhxvM2kUmHivEXOzN9
	GZgla+uA8QgAM95qhu5B0XZlq20eqXvxBlUoCcVpd3msQSroKIv3fDHhgTUb3HEKGuA==
X-Received: by 2002:a25:d314:: with SMTP id e20mr21877979ybf.271.1556033459654;
        Tue, 23 Apr 2019 08:30:59 -0700 (PDT)
X-Received: by 2002:a25:d314:: with SMTP id e20mr21877922ybf.271.1556033458995;
        Tue, 23 Apr 2019 08:30:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556033458; cv=none;
        d=google.com; s=arc-20160816;
        b=pa/z2PMuHtfakBdC+hkPrqXZS4gUGDFjGXCK0nWQQy7Dqm9iyxmKJPZ5lA95OTGQOO
         LJA3OZgtcb+feMbaWnEVSStnOXf/3Ry7OFC2yzou6oJMXGaSZmuMtvMIdsxb+txvJqTp
         cKE8LZsArdWxxzixW8LUo5161PcMVBvvt6q8hunSVBuOXVz0K+aSBs43XGkO/VmBUWYT
         u/zjWlF3fSdBkQ19ff2mDCCgUJ65PdoHGTqLgfV5oAfGFj8ztbxDO9dTDT65tQHDpzM2
         DR35HcZne6mOEz1SBdx+b5gg5t3TC+uIvNeoBfTsefW1Ye7YCzcxXM5Mi2Aqy4t95cef
         isaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=yEsJunfUbaZmio+edIZHR7uNumWd1MHNzVqBngWscks=;
        b=c8cwnjsLTj6FTjHS4bipym32j3hzyy1uJu+2L2xflzgqZ3Rt4pCRLKa7uNNTW3rzct
         ryRnITpGjE5DjLRBCx511nFTSagcUECRBTFrZgAv7xygaC3OY+Jgr9KYA+U7LrCw8EJ/
         wdc1SuJ1u7qAhLKHhbMSkqkklvvSErIobZeVny8Nm/fXIgZy+nz/Ku5lPL9xYty2uqhj
         aWQvre4MaRMCET4uYLJekWMDa/LqktXbyisAtlZikQgolR8SuqS8sqn2cxyowVExmnqr
         G8mCvb2oPHBZ9kKPj3m2KNgQVwusfyTyhGR0KVUjdlXuTPyQemUlmjoWo+XLSpS/OKAc
         GwDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jaJ2fkwH;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 139sor7001096ywg.99.2019.04.23.08.30.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 08:30:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jaJ2fkwH;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=yEsJunfUbaZmio+edIZHR7uNumWd1MHNzVqBngWscks=;
        b=jaJ2fkwH1mCx0hopdYwEXAa6YwETI3xUruPfHlDIT+EBBuYIC7jKH+kYeGmrn3J0KV
         0K7M7FOYTg7yEL+VytFmj7npBJvQVcXJXUk13yMyhXSUboKKBm03V0l4JPmtghQDeyWH
         kPp9DTwV6sGINI/qX5HziGPtLxUwsW/HYNElIgtCt5vj6r1G7posqTw+8/D5wI2lapP5
         8rdrGSuFUoL1oVf1K7qxdM39NhmrUB5RQtwAOyJDqAXxH7Y1jtozkhQVS/JrNttthJLR
         YiUjQalCCpRyXkjbgBWGPXqWVvB7FyDUhFt2ts1+3hiwB+swCoz/xlMAf52ZaBJiWXw3
         LnTw==
X-Google-Smtp-Source: APXvYqznU3B5y7vUTJV9lSTCzlHB67tsYye4b9R5i29Jr3eQ7gJOeRnV8BkHalFoUNQz4NeVqVqTcHq6UOv9tX23lrs=
X-Received: by 2002:a81:2204:: with SMTP id i4mr21278665ywi.349.1556033457993;
 Tue, 23 Apr 2019 08:30:57 -0700 (PDT)
MIME-Version: 1.0
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 23 Apr 2019 08:30:46 -0700
Message-ID: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
Subject: [LSF/MM TOPIC] Proactive Memory Reclaim
To: lsf-pc@lists.linux-foundation.org
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Though this is quite late, I still want to propose a topic for
discussion during LSFMM'19 which I think will be beneficial for Linux
users in general but particularly the data center users running a
range of different workloads and want to reduce the memory cost.

Topic: Proactive Memory Reclaim

Motivation/Problem: Memory overcommit is most commonly used technique
to reduce the cost of memory by large infrastructure owners. However
memory overcommit can adversely impact the performance of latency
sensitive applications by triggering direct memory reclaim. Direct
reclaim is unpredictable and disastrous for latency sensitive
applications.

Solution: Proactively reclaim memory from the system to drastically
reduce the occurrences of direct reclaim. Target cold memory to keep
the refault rate of the applications acceptable (i.e. no impact on the
performance).

Challenges:
1. Tracking cold memory efficiently.
2. Lack of infrastructure to reclaim specific memory.

Details: Existing "Idle Page Tracking" allows tracking cold memory on
a system but it becomes prohibitively expensive as the machine size
grows. Also there is no way from the user space to reclaim a specific
'cold' page. I want to present our implementation of cold memory
tracking and reclaim. The aim is to make it more generally beneficial
to lot more users and upstream it.

More details:
"Software-driven far-memory in warehouse-scale computers", ASPLOS'19.
https://youtu.be/aKddds6jn1s

