Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83915C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:07:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3529320693
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:07:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IDIcj4x9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3529320693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE7146B0005; Thu, 18 Apr 2019 18:07:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6E6A6B0006; Thu, 18 Apr 2019 18:07:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12336B0007; Thu, 18 Apr 2019 18:07:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B15B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:07:45 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id y127so3687091itb.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:07:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pG9se1HaWlSZ+DXQi3Pi/3sZPJFsOD15gEOGUdPXO4o=;
        b=QD/cSZOkHZwoOUWyYW2P8BTkN6HSWjSExZ6dZ5oqjszoKEalrRMFpjSkh41vNY0QH/
         MlG6v06wG8NHgFW2aYiIvWVhbhxC8eNFFdu2hE3OtwcykuLFRxtFGW+jlCLDpIIqL1+S
         G9w//emhm22+FEzKa+jQNVSqemVQXkstYf+f/WiUFetlSY8OWrfuvZOLUNrN6qnFjZEv
         RhTBgSY+CWx6nXd27CX0V7TvkDz9EtbJFUhblLN+Nx26ky8kZS4JzNm7I3a7o3eNh5Jw
         d9A+TU9bbbFuOfDQ0Zmht70B6T2nAzydG7fQO2yi8Unxk/DKApqsH6D3zmzlhRPbE8Ds
         O9BA==
X-Gm-Message-State: APjAAAXDcBdP8wkRJN7Et+9nw4EKY9qnM594j8rxrEGXtI7DzZOtz80J
	rtERJnYO8Z6lBrSP1bbXo9trZsNRaSdHFB2H+1QXLUYGz5uqzHBDmkvEdDRxoMrByRNn64ygq6D
	5AZZ1vvoSvdmmVImUXULw7vpNdW/cGUqJySXtTbjye4gOS9Z5AwvfJVYRzewXNNzuDQ==
X-Received: by 2002:a24:7a8b:: with SMTP id a133mr270723itc.118.1555625265267;
        Thu, 18 Apr 2019 15:07:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBM2vN/ezJ7KDiRht1L/bCD3x/2oRwKEH683BF5BxEwJZsa5PihaH2qo6htoO+IM9IzKeA
X-Received: by 2002:a24:7a8b:: with SMTP id a133mr270675itc.118.1555625264551;
        Thu, 18 Apr 2019 15:07:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625264; cv=none;
        d=google.com; s=arc-20160816;
        b=h9r91zLN8aiT0LZ4ysCmHeTFM9QB/m3Y9109cpSAS2OrKCObfxKvXkgS5TcbH2DPfk
         QkFC+EHUYIJz3EUE/EUIxy3XUgtAVGhbd5KD+xHV7zuu5uHz9jaxtBjU2ZVkEGKzQqZZ
         aiughPapdlGh3sPNYMYgH1N/BwwPSXdiCbGXCVhqp5XJG73Uy33ZgQYvKQJHIrehO7L3
         06C/P7G+lQto72/IleGsNNE9Sg1LOR66onlFRufYBPJKLhcxipiBeMyYoFwMpirQWrSl
         DzRG1AfdVSEtZ0gYw6egCpBLkAxKYKTD3C83vAplooebJj9XtVSLCgt02jjARMeiQ7U2
         5h4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=pG9se1HaWlSZ+DXQi3Pi/3sZPJFsOD15gEOGUdPXO4o=;
        b=dPfZRaoNBXdFlBSSvB3NTEeaWhnbbbzqOLCLOcfWSu4L0cq58BTMbHHgzuRst7vmuN
         LNhpE8vtX9m3upVBp0VqPC7vm7sKbicIHdYxX+9k1WO6awDeelX7eoOwrf2o5uLhWX/O
         RfSTpt38lxMXCcgypnLXqsZkeB0Ba1i/BziSIdT3/OqaCsZPAICYZ7HzvQxT7I7NY2O/
         qOG3ZiKHZF0fp6m989sNfVx7xG6hL72hmd6oLGU8Zd8Oqopxt10L+krzrjLrdUMG1vG0
         ZhBxHPKITBMUa7HQL2wNUzcmm3kVzVRHFJo9RFP5+ci+epJV03a4hNiKRSdOHHKYNo+i
         +V/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=IDIcj4x9;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 5si2033734itz.6.2019.04.18.15.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 15:07:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=IDIcj4x9;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=pG9se1HaWlSZ+DXQi3Pi/3sZPJFsOD15gEOGUdPXO4o=; b=IDIcj4x9mvvPQTrQYXHpVzGU1p
	TzVdpyBuYpJkySI/wzdvMv3FcoMnHL9MGh3smBmNL7zALHBhmjrp6XbCk0k4du7mnrO6Krcbx6/Aq
	b29+oedPRaIkarM/ioIejZadcm6Qn+/nv2moO1bTXWiZ+RBgGhRTg3ePo6hdvREzuXmvqxaQ51mbQ
	i7pxA8NZM8MWRlRUC6DoIgPksF9vO5pS0ebCNvVk9Atzyf0ylwheZRNh5bokHlMSzqGmCJFSI28z4
	3HzdVSLTQ74L80eu1V5PkpQ1kR2JlHTYYh8rGH47EQLKtBW93CsFHXouq5xWLnCbqu0iAP4NZ1/mO
	1vP6l9zQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHFBz-0007OA-IP; Thu, 18 Apr 2019 22:07:39 +0000
Subject: Re: [PATCH 0/3] RFC: add init_allocations=1 boot option
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
 cl@linux.com, dvyukov@google.com, keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com
References: <20190418154208.131118-1-glider@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <79967fc5-fd7b-b16d-8ff7-0847396ff4f5@infradead.org>
Date: Thu, 18 Apr 2019 15:07:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418154208.131118-1-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> Following the recent discussions here's another take at initializing
> pages and heap objects with zeroes. This is needed to prevent possible
> information leaks and make the control-flow bugs that depend on
> uninitialized values more deterministic.
> 
> The patchset introduces a new boot option, init_allocations, which
> makes page allocator and SL[AOU]B initialize newly allocated memory.
> init_allocations=0 doesn't (hopefully) add any overhead to the
> allocation fast path (no noticeable slowdown on hackbench).
> 
> With only the the first of the proposed patches the slowdown numbers are:
>  - 1.1% (stdev 0.2%) sys time slowdown building Linux kernel
>  - 3.1% (stdev 0.3%) sys time slowdown on af_inet_loopback benchmark
>  - 9.4% (stdev 0.5%) sys time slowdown on hackbench
> 
> The second patch introduces a GFP flag that allows to disable
> initialization for certain allocations. The third page is an example of

                                              third patch

> applying it to af_unix.c, which helps hackbench greatly.
> 
> Slowdown numbers for the whole patchset are:
>  - 1.8% (stdev 0.8%) on kernel build
>  - 6.5% (stdev 0.2%) on af_inet_loopback
>  - 0.12% (stdev 0.6%) on hackbench
> 
> 
> Alexander Potapenko (3):
>   mm: security: introduce the init_allocations=1 boot option
>   gfp: mm: introduce __GFP_NOINIT
>   net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations
> 
>  drivers/infiniband/core/uverbs_ioctl.c |  2 +-
>  include/linux/gfp.h                    |  6 ++++-
>  include/linux/mm.h                     |  8 +++++++
>  include/linux/slab_def.h               |  1 +
>  include/linux/slub_def.h               |  1 +
>  include/net/sock.h                     |  5 +++++
>  kernel/kexec_core.c                    |  4 ++--
>  mm/dmapool.c                           |  2 +-
>  mm/page_alloc.c                        | 18 ++++++++++++++-
>  mm/slab.c                              | 14 ++++++------
>  mm/slab.h                              |  1 +
>  mm/slab_common.c                       | 15 +++++++++++++
>  mm/slob.c                              |  3 ++-
>  mm/slub.c                              |  9 ++++----
>  net/core/sock.c                        | 31 +++++++++++++++++++++-----
>  net/unix/af_unix.c                     | 13 ++++++-----
>  16 files changed, 104 insertions(+), 29 deletions(-)
> 


-- 
~Randy

