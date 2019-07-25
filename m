Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DAD4C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BE7921901
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:52:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="fk5PxdqX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BE7921901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7DE6B0006; Thu, 25 Jul 2019 14:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B78C66B0007; Thu, 25 Jul 2019 14:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3E658E0002; Thu, 25 Jul 2019 14:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82EF16B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:52:52 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id v20so13552899vsi.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=w30g8iTJZ+UU2qLPrb+evOZb5z9OWHBiOGbGq1jemNU=;
        b=lRRTofUIhFLQzh8jR4foisKPbnulhskMtVk0VQjEzxqZu5vj3YlRZZAfFs7/DOqxuK
         SnadMLtOcWOxEml/nqoyoZjzrQkxrlN1FFFAS2sM3LokkgPQ6W+uJVfVhiz1KflW1J3y
         ZL8R9OBKJyQQtNwytAIvHyDF15ewleJXhfQBKLQ9aOTiNPJW/JLIzwb75fBuq+1nBj7r
         NsqFV4slMNVMQsRhJoBDtsaC57BvPaKCQ5X69SeTwJgQmoJXjQro6ij4D52x3eF88cyt
         cV01B8N8qziyh1hIUA3qkHY/Q2+X3O3DkIopDqyVkYiK6VgIx/lcK9LKeWqp9Pdasf6I
         tHRg==
X-Gm-Message-State: APjAAAXxosYp08bz0LKFsuxUVeUtebCg7b4FUfaXHP8zWc2mKW5xXPy4
	qQsVgG9C0Q+yRhndwJka0UyGL3EkrpBcBvdyExhO81wjnUyKXob1omcF1sC6vjWcl75LVOM4GQ/
	bB9kgT41pliQu38tA+lO0YlcoPcjBV8eIwA7+7xeudtYDweQbFaT0QJWpqo3wPpUueg==
X-Received: by 2002:a67:ff0b:: with SMTP id v11mr23873476vsp.14.1564080772206;
        Thu, 25 Jul 2019 11:52:52 -0700 (PDT)
X-Received: by 2002:a67:ff0b:: with SMTP id v11mr23873416vsp.14.1564080771556;
        Thu, 25 Jul 2019 11:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080771; cv=none;
        d=google.com; s=arc-20160816;
        b=BsTRTX8lWqII49JJ6Es/21OuyGAz9Mj5rSmFAGNXeDPDSpviagy2E1i5xCzKSVANwO
         GY31DXD5XZaKvwQgfeTTVlaWP04gfGriMmOhaXzsR5g78V11V41MfkmSxK74plD9UfOY
         hbsYZm2XAM89I3QCvtnb1+j8MfaFD+RfYnSj27sy7KoqMqvK2lg1wHNK9tH2+gLQ66Tp
         fg6rHVV3aqbYLn8dTOhxtIxpzDSek17dpYBwqXzsR6UGfNDKjgbKHqVK5LwGPEOqgQ3S
         p/iB2A8Lrc1If/9eGJq52G895RZKXbAoI0LayD+7dZYQBYFkXvgveoeWvfCJHYoL55jU
         rZ4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=w30g8iTJZ+UU2qLPrb+evOZb5z9OWHBiOGbGq1jemNU=;
        b=MK6VXlLkS+OfuMJXJ0381oZe6p1UeEDORlXnBNkZKh2Im5e5tFJqvXd1k5W5hzqbbN
         FeC9pWK/kt3x2xpH3MQn5u8Kn6+FIbtBBA11+XD+a0Pzq5fqKyEaDNdES3duSS/7fBkC
         1UqQmgZM+cRNkqRWI9ICFz1SnbmkJ7LB2BiBrMJCI0+ZFxUPEzKAieUawvB8knA7RudB
         iKyvmismf0PSPOxUPFKEDw4E41AHhkTKLKWgVI0VuT7AyN0uTWPv5jQADJRX9D5IvAqQ
         axd+dEjK6c7vxDrR/vNqKQtyDO5r8MHIZq7mFi6trpr5JxJinF5bYfDwyekMTCX2J8iS
         2yQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fk5PxdqX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 53sor24629658uae.55.2019.07.25.11.52.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fk5PxdqX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=w30g8iTJZ+UU2qLPrb+evOZb5z9OWHBiOGbGq1jemNU=;
        b=fk5PxdqXwDMPwORg3XCxFG7uAIyVeAxzjCVFr+xY1GzC38VvJWux97NE9QX+CMxCWT
         dW04AcGMPDsLPV36Mle3sHH8SfBxjOIw/qUNl8V7ZhAGicnLTjfSfmoBiocxOZZg4bsX
         GueHeMwj15Cu7ORpM8BNUmrifrXhJs/fxE9WQyPlh1AHJW8e1ZDTzDFM3b2Y8A8cZ5Ee
         Zym/8PjXzAcatIUnO7Fm1FMiiuJMEr9QWCVp9O3lKHrMoKEn4pG7flqM/1RgO/i7Tp5H
         NB1nrOVWLfVvMaxoRs94O2pNu7mq8vhq1LjdJr0p7wEW5WxeQ6k84EitR4kgT4ZHfBrk
         8fPg==
X-Google-Smtp-Source: APXvYqzR+uo0BYzmmM09fGdkgM3r83aj04Jvid8uh+HP6b+ewHzxQIVEd/JNaC3+NAmqGGBGmAZ9Hg==
X-Received: by 2002:a9f:2269:: with SMTP id 96mr55944133uad.80.1564080771058;
        Thu, 25 Jul 2019 11:52:51 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id l20sm15288616vkl.2.2019.07.25.11.52.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 11:52:50 -0700 (PDT)
Message-ID: <1564080768.11067.22.camel@lca.pw>
Subject: Re: [PATCH 00/10] make "order" unsigned int
From: Qian Cai <cai@lca.pw>
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, 
 aryabinin@virtuozzo.com, osalvador@suse.de, rostedt@goodmis.org,
 mingo@redhat.com,  pavel.tatashin@microsoft.com, rppt@linux.ibm.com,
 linux-kernel@vger.kernel.org,  linux-mm@kvack.org
Date: Thu, 25 Jul 2019 14:52:48 -0400
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-26 at 02:42 +0800, Pengfei Li wrote:
> Objective
> ----
> The motivation for this series of patches is use unsigned int for
> "order" in compaction.c, just like in other memory subsystems.

I suppose you will need more justification for this change. Right now, I don't
see much real benefit apart from possibly introducing more regressions in those
tricky areas of the code. Also, your testing seems quite lightweight.

> 
> In addition, did some cleanup about "order" in page_alloc
> and vmscan.
> 
> 
> Description
> ----
> Directly modifying the type of "order" to unsigned int is ok in most
> places, because "order" is always non-negative.
> 
> But there are two places that are special, one is next_search_order()
> and the other is compact_node().
> 
> For next_search_order(), order may be negative. It can be avoided by
> some modifications.
> 
> For compact_node(), order = -1 means performing manual compaction.
> It can be avoided by specifying order = MAX_ORDER.
> 
> Key changes in [PATCH 05/10] mm/compaction: make "order" and
> "search_order" unsigned.
> 
> More information can be obtained from commit messages.
> 
> 
> Test
> ----
> I have done some stress testing locally and have not found any problems.
> 
> In addition, local tests indicate no performance impact.
> 
> 
> Pengfei Li (10):
>   mm/page_alloc: use unsigned int for "order" in should_compact_retry()
>   mm/page_alloc: use unsigned int for "order" in __rmqueue_fallback()
>   mm/page_alloc: use unsigned int for "order" in should_compact_retry()
>   mm/page_alloc: remove never used "order" in alloc_contig_range()
>   mm/compaction: make "order" and "search_order" unsigned int in struct
>     compact_control
>   mm/compaction: make "order" unsigned int in compaction.c
>   trace/events/compaction: make "order" unsigned int
>   mm/compaction: use unsigned int for "compact_order_failed" in struct
>     zone
>   mm/compaction: use unsigned int for "kcompactd_max_order" in struct
>     pglist_data
>   mm/vmscan: use unsigned int for "kswapd_order" in struct pglist_data
> 
>  include/linux/compaction.h        |  30 +++----
>  include/linux/mmzone.h            |   8 +-
>  include/trace/events/compaction.h |  40 +++++-----
>  include/trace/events/kmem.h       |   6 +-
>  include/trace/events/oom.h        |   6 +-
>  include/trace/events/vmscan.h     |   4 +-
>  mm/compaction.c                   | 127 +++++++++++++++---------------
>  mm/internal.h                     |   6 +-
>  mm/page_alloc.c                   |  16 ++--
>  mm/vmscan.c                       |   6 +-
>  10 files changed, 126 insertions(+), 123 deletions(-)
> 

