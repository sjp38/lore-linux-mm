Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6498CC4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:16:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DB0B206A4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:16:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ie+MVgQk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DB0B206A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B6B6B0003; Mon, 16 Sep 2019 16:16:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADCD96B0006; Mon, 16 Sep 2019 16:16:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F29A6B0007; Mon, 16 Sep 2019 16:16:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECC36B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 16:16:39 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0F0A4181AC9B4
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:16:39 +0000 (UTC)
X-FDA: 75941891718.20.tooth74_914a9c8e01702
X-HE-Tag: tooth74_914a9c8e01702
X-Filterd-Recvd-Size: 7034
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:16:38 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id w10so396421plq.5
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:16:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=l7XNvVLoq2DkM/BJzCh4tZgRffWcTPePk08fCu1QvA4=;
        b=ie+MVgQkv+or+j8rP4f5XQk3UqeS/AWrMIsnBe6inekVRMwuNTTlDKwqToPjtv6V9q
         0CyusXtPz1lH21Zxc7HfH1A7Dy8y5y9lg8DlZte+zLDTVs4b2KVTU2bE/oDr0Lkl/+66
         pCZ7z1W7G7/Pz6Kc+SsfA+W5diGDbUbYLrsd6aiXgXx5syZBXxOaJPKj+kqcAnKSFUSr
         ms8XPC2Znhix8Yfhw6MX0Iva5i2umckTNgjTHZ122ws7+cF4/gjAWKtC7X3MefyHi2LT
         rgbqPj3L6f0tdi5b6jiJOiEJcn6F0ZhqkenvfvfvM6KlxO5UogNKVA63h0MVlfGEYCNO
         CRyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=l7XNvVLoq2DkM/BJzCh4tZgRffWcTPePk08fCu1QvA4=;
        b=KLdfYKuwFlKyXS/OrPgbuawU0+yBLnUboWRkFLqQmsRB25irzO78auhtTmhecuT9ox
         ExGsje6HCvYcH7X4NL3ZbGDkRyIW+Rw9mdFGHT4GFZlF6J7IuZ/W9Z8bIbWlTJRntdIu
         hf8Ltso40E+hAJ9rvzvXSVMtG+JUm8DFYf74KmKlCuFHOhdDifC2fg5AI2ly9cDpTHL+
         iD6HXI4x5+7rL1GyK8HiAJPD0XAbocJvOvgA5H3z4biUN8BFUlhz1y9aP+Q9uVciW/pA
         mkxkKRnSXT8sqq99tGREiOyI3gVUQ6Eucmf4/QGLm+FvCfzbT5vAfooFYSE3PKHWxvNC
         2WUg==
X-Gm-Message-State: APjAAAWcTKHV0/tt2ubDjDR80LlBrR3odUQyM0qoSqFdO9h2RQ6ZSpdH
	FhtC3jA1INIu7/izAtOXIqNqwQ==
X-Google-Smtp-Source: APXvYqx2hmHwDoJZ/3qpQxbgGsD8dEe6G4dJVFtxE38EZu//CwuUSX16507Bl74A6tpjxXSEhCW5rA==
X-Received: by 2002:a17:902:426:: with SMTP id 35mr1740575ple.192.1568664997050;
        Mon, 16 Sep 2019 13:16:37 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id l62sm61892849pfl.167.2019.09.16.13.16.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 13:16:36 -0700 (PDT)
Date: Mon, 16 Sep 2019 13:16:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Nitin Gupta <nigupta@nvidia.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, 
    mhocko@suse.com, dan.j.williams@intel.com, Yu Zhao <yuzhao@google.com>, 
    Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, 
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
    Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, 
    Johannes Weiner <hannes@cmpxchg.org>, Arun KS <arunks@codeaurora.org>, 
    Janne Huttunen <janne.huttunen@nokia.com>, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC] mm: Proactive compaction
In-Reply-To: <20190816214413.15006-1-nigupta@nvidia.com>
Message-ID: <alpine.DEB.2.21.1909161312050.118156@chino.kir.corp.google.com>
References: <20190816214413.15006-1-nigupta@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Aug 2019, Nitin Gupta wrote:

> For some applications we need to allocate almost all memory as
> hugepages. However, on a running system, higher order allocations can
> fail if the memory is fragmented. Linux kernel currently does
> on-demand compaction as we request more hugepages but this style of
> compaction incurs very high latency. Experiments with one-time full
> memory compaction (followed by hugepage allocations) shows that kernel
> is able to restore a highly fragmented memory state to a fairly
> compacted memory state within <1 sec for a 32G system. Such data
> suggests that a more proactive compaction can help us allocate a large
> fraction of memory as hugepages keeping allocation latencies low.
> 
> For a more proactive compaction, the approach taken here is to define
> per page-order external fragmentation thresholds and let kcompactd
> threads act on these thresholds.
> 
> The low and high thresholds are defined per page-order and exposed
> through sysfs:
> 
>   /sys/kernel/mm/compaction/order-[1..MAX_ORDER]/extfrag_{low,high}
> 
> Per-node kcompactd thread is woken up every few seconds to check if
> any zone on its node has extfrag above the extfrag_high threshold for
> any order, in which case the thread starts compaction in the backgrond
> till all zones are below extfrag_low level for all orders. By default
> both these thresolds are set to 100 for all orders which essentially
> disables kcompactd.
> 
> To avoid wasting CPU cycles when compaction cannot help, such as when
> memory is full, we check both, extfrag > extfrag_high and
> compaction_suitable(zone). This allows kcomapctd thread to stays inactive
> even if extfrag thresholds are not met.
> 
> This patch is largely based on ideas from Michal Hocko posted here:
> https://lore.kernel.org/linux-mm/20161230131412.GI13301@dhcp22.suse.cz/
> 
> Testing done (on x86):
>  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} = {25, 30}
>  respectively.
>  - Use a test program to fragment memory: the program allocates all memory
>  and then for each 2M aligned section, frees 3/4 of base pages using
>  munmap.
>  - kcompactd0 detects fragmentation for order-9 > extfrag_high and starts
>  compaction till extfrag < extfrag_low for order-9.
> 
> The patch has plenty of rough edges but posting it early to see if I'm
> going in the right direction and to get some early feedback.
> 

Is there an update to this proposal or non-RFC patch that has been posted 
for proactive compaction?

We've had good success with periodically compacting memory on a regular 
cadence on systems with hugepages enabled.  The cadence itself is defined 
by the admin but it causes khugepaged[*] to periodically wakeup and invoke 
compaction in an attempt to keep zones as defragmented as possible 
(perhaps more "proactive" than what is proposed here in an attempt to keep 
all memory as unfragmented as possible regardless of extfrag thresholds).  
It also avoids corner-cases where kcompactd could become more expensive 
than what is anticipated because it is unsuccessful at compacting memory 
yet the extfrag threshold is still exceeded.

 [*] Khugepaged instead of kcompactd only because this is only enabled
     for systems where transparent hugepages are enabled, probably better
     off in kcompactd to avoid duplicating work between two kthreads if
     there is already a need for background compaction.

