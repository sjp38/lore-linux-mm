Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A2A0C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 06:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDA6020815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 06:37:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDA6020815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50AEF6B0006; Mon, 20 May 2019 02:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 495236B0007; Mon, 20 May 2019 02:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35D046B000A; Mon, 20 May 2019 02:37:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8F0B6B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 02:37:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n52so23701845edd.2
        for <linux-mm@kvack.org>; Sun, 19 May 2019 23:37:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=s0XqirjLJZRgntQEz1NJdbFOSqFoBHPPpWP02WQVEHM=;
        b=oOoHvXsUIz9ZuKMGRI5A0ZdoEIoSDq41Ln7kcKOBM3qviiipxyeKVIXA0ZkMQLLfe9
         6+D0qQGbEsg7NdsWTx5d+z8rbc1v6GCAenheabiHAUi9oSf4d1RoYLQOV4IsRZet0XTM
         zscRcCk3X5wltD30lp/oYYg7nnRVcDOi3tI6/V3WYVcVyT2ivBdA414MFU2JXoIrO4B1
         samw6B0OqlAohnDq03RdCqeB2GZOEZiVEsODbUVzYXCeOmFoHFahczX0oWTcU+3Zg48h
         E/P+d4XICd3iFJg3qvQv440KzIa41ZVgBMhrdFF2Uv0dfDtialwOGS9P7UXl4zkIMdc4
         yUMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWeUVuuoTI/L9jLJJAPRRvm7Yzp6spIcXS8lMz0luYKWFPcY66f
	WeFACF6OZLytJLIayZUzgDk/hHT5Zs9DxjgpgU0ioJLIxYeCdbj2jouVGNB/4fTPDjnro0SUVut
	O/RnssVpAV3+BHvvB3e2K0ta/YrFJ+YuXU2Na/Qqn+at617lb9NVIoewGxSKeO53D1g==
X-Received: by 2002:a17:906:d508:: with SMTP id ge8mr718893ejb.200.1558334255289;
        Sun, 19 May 2019 23:37:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMKKR3LxrUVNpSNgxSMC04FMZQk6+MrBbiVUm1PGLObfjkJeHHU4iknZvWxcfjI8M105Lu
X-Received: by 2002:a17:906:d508:: with SMTP id ge8mr718851ejb.200.1558334254552;
        Sun, 19 May 2019 23:37:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558334254; cv=none;
        d=google.com; s=arc-20160816;
        b=MENYnI735FZrktNX5jbOtW9+mhGhPiLHRM6MkfB8LTA0KItSDXEeawCjLQPt14DUXy
         4lNcZa0qGdN6WK85u1M7RPLYgnWGdXPP119azLwoIBXI8vdGlF/DARoSRTEKoXVdcaeW
         FwJHbjqxoVMjt93u2RV1LYeBq/yDhVpjJxzQntPCz7An3UCm3XDnXoB+/Ob5PqelgVHk
         X5cfe0CoQ0n0/bDi/HdFw9AEcHmIDYHVj9ruylV659ip95p0G/qoybWaHHcqKFthzhk8
         eHZqeNtA1VcEA8AFAzGy1W2+sKZFut0bNWG35AiPZKWUIGUig+LgodbZyqtV4Gn58pw3
         MNKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=s0XqirjLJZRgntQEz1NJdbFOSqFoBHPPpWP02WQVEHM=;
        b=x/W6/0wetSKxvWk40oAg5k6Dwa+/tKb/IXErwStSEUPMDfpfdxEBmxlzDfCx+y/53i
         Wm8i8kH2nSezU8pOjSJ+VgOQ7m0J415mvdzrCHhRE264vFVvt2OZ8/sHGMgS1UG0kYpg
         Bbr5agHuGLuS2WZau6M08K2C951rVnOakXqz8C1fj9z6smZXHLnjs6WJplSiHtKF5T75
         quAmBALdcwS0HlSzfcgW0qRMEHHiOfPej+EeH44lmF9POELxuwUkaPlWiHXKyniz8bW0
         muB04P+ce5d9qSYsnN3CdGI+grlCxQLjNK+BaPwnQVnUeV9/JSuBYPoSZhhv/5sqs/tG
         JinQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u17si6033468ejx.387.2019.05.19.23.37.34
        for <linux-mm@kvack.org>;
        Sun, 19 May 2019 23:37:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 571BA80D;
	Sun, 19 May 2019 23:37:33 -0700 (PDT)
Received: from [10.162.41.132] (p8cg001049571a15.blr.arm.com [10.162.41.132])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 34EA53F575;
	Sun, 19 May 2019 23:37:28 -0700 (PDT)
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Minchan Kim <minchan@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>,
 Suren Baghdasaryan <surenb@google.com>, Daniel Colascione
 <dancol@google.com>, Shakeel Butt <shakeelb@google.com>,
 Sonny Rao <sonnyrao@google.com>, Brian Geffon <bgeffon@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
Date: Mon, 20 May 2019 12:07:42 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/20/2019 09:22 AM, Minchan Kim wrote:
> - Problem
> 
> Naturally, cached apps were dominant consumers of memory on the system.
> However, they were not significant consumers of swap even though they are
> good candidate for swap. Under investigation, swapping out only begins
> once the low zone watermark is hit and kswapd wakes up, but the overall
> allocation rate in the system might trip lmkd thresholds and cause a cached
> process to be killed(we measured performance swapping out vs. zapping the
> memory by killing a process. Unsurprisingly, zapping is 10x times faster
> even though we use zram which is much faster than real storage) so kill
> from lmkd will often satisfy the high zone watermark, resulting in very
> few pages actually being moved to swap.

Getting killed by lmkd which is triggered by custom system memory allocation
parameters and hence not being able to swap out is a problem ? But is not the
problem created by lmkd itself.

Or Is the objective here is reduce the number of processes which get killed by
lmkd by triggering swapping for the unused memory (user hinted) sooner so that
they dont get picked by lmkd. Under utilization for zram hardware is a concern
here as well ?

Swapping out memory into zram wont increase the latency for a hot start ? Or
is it because as it will prevent a fresh cold start which anyway will be slower
than a slow hot start. Just being curious.

