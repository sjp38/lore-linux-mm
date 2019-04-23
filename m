Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC8F3C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:58:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A06E206BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:58:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A06E206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 306CA6B0007; Tue, 23 Apr 2019 11:58:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B5A86B0008; Tue, 23 Apr 2019 11:58:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17E826B000A; Tue, 23 Apr 2019 11:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC4626B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:58:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x21so5938245edx.23
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:58:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TOVxhoWJQfWZ9cm4H7M+/UN1Da8A5jzewwNCpDKo2sQ=;
        b=W9sR83BDlAO9mN5jy5bf7aQWC0xkSyK7Ocdi624kQIDLbuypMSCuIwwowLlimtRMht
         Pq5tIX4s9aF/6bZxQ9RKR69+pdUQl4LQm3uHOgT6oVpdqKl1ytVP3BjA1FYELvMnAKiR
         WEWiAF2YSbhSyt9WWY3UcdrpsInehkHlUiQSn6PqjC3mEJI+YfvAsjEF7Z0vFaWTF9dh
         pFvRW8bcC4Rw6EI0VanyEKGHAkJ1wKbQLPIZRu5oftR82c8OPQZ9Hn2XUjDI8uFlLPe4
         i0swUcgoz0wv5pnGQkReGGydzAj7NkLqAVSow25mc5bkw+dLeuf0ojJiHO4TOZijyzYq
         B6MQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVcTv9uYvqpV1Utg24FS//Q63VbChwWinmNCNiWASlcUt8rLyJ4
	z7+oZwgLWRqX2tB049F+JLx2pAaErkfudLW96jn3jZ7SM4hw15yDCcxPSCFniUpNU9aLaQGGGhb
	zcN04b2+xFjAkqSYWLmXk/jdsEifCeS3gAK5hLCZvYllEMW4ZnRJQ3QDf0SnVsfDOOQ==
X-Received: by 2002:a50:a705:: with SMTP id h5mr16386835edc.226.1556035110303;
        Tue, 23 Apr 2019 08:58:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsCVlN2EXKGrkNHpsBh67TXlt3EWC2qkuuLbemI8sojYxKxrUFPeIptaoNo3+keGr9p9UE
X-Received: by 2002:a50:a705:: with SMTP id h5mr16386792edc.226.1556035109461;
        Tue, 23 Apr 2019 08:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556035109; cv=none;
        d=google.com; s=arc-20160816;
        b=D8uRVCk6/md/0QfL/guGCo/H6vyxOdHlPZTnDEEr/YH5MLAQzFbeOB2b0NyL38PQvO
         dmoTedqoIPSRZX6YS30RJBWoVxreFiJnHAhu3NZW3uJefR8joMwW6SZCwuKGDU5ILdpp
         IQyyuYFOjROHzpf4R19A4v8neWTaz3yqWvUZsj1kBdyw3k6fO7uRbYwmTagoDWMd+J0U
         /QbVcHNFHVvjqHpn07yYtDe7Do+vS9HEQltzdNPxxyEgXb2zYnbe9xmHbwma5T1KOB/T
         QmG4A0h6g06hP2/JVgWBBrmvc0eVGJ1zap2Uy2OgsFRo0NVWpgX0ftiFG7ofTjS/0GIE
         ufRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TOVxhoWJQfWZ9cm4H7M+/UN1Da8A5jzewwNCpDKo2sQ=;
        b=au70iCSQBEPBuKWWGeY6H3+BpgSeHY7nLZJXO7NsqJ/018i2pPNu5/g5h+qjHjT9XA
         bj74TVMY3xwcfZfJG0TFtAI2yZYBpP3vftyW2lhN7KhyGswpxxIt8zBR7yI8XOhXSGOY
         AolQuR79AY0sErGcquy17gVW3lcjCx8/Fh85grBI0uOfhsBSZi8AmXyPnKUH/TeaE+TN
         bo6KRITNq1r5PGuYD6BRWk90S6Ge8/2S7XEEs5WU6F3vuD4nEF2MmquajUJijVMNmZ0Y
         t6mgTv7tjUs1cKz8hdxFTWA0v094RRExFuCi9GvJXtXDNygMMFYGlBm5B2zv5IMKhskY
         U71g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id k9si3570062edb.435.2019.04.23.08.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 08:58:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id AF82E1C267E
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 16:58:28 +0100 (IST)
Received: (qmail 14497 invoked from network); 23 Apr 2019 15:58:28 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 23 Apr 2019 15:58:28 -0000
Date: Tue, 23 Apr 2019 16:58:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Shakeel Butt <shakeelb@google.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
Message-ID: <20190423155827.GR18914@techsingularity.net>
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 08:30:46AM -0700, Shakeel Butt wrote:
> Though this is quite late, I still want to propose a topic for
> discussion during LSFMM'19 which I think will be beneficial for Linux
> users in general but particularly the data center users running a
> range of different workloads and want to reduce the memory cost.
> 
> Topic: Proactive Memory Reclaim
> 
> Motivation/Problem: Memory overcommit is most commonly used technique
> to reduce the cost of memory by large infrastructure owners. However
> memory overcommit can adversely impact the performance of latency
> sensitive applications by triggering direct memory reclaim. Direct
> reclaim is unpredictable and disastrous for latency sensitive
> applications.
> 
> Solution: Proactively reclaim memory from the system to drastically
> reduce the occurrences of direct reclaim. Target cold memory to keep
> the refault rate of the applications acceptable (i.e. no impact on the
> performance).
> 
> Challenges:
> 1. Tracking cold memory efficiently.
> 2. Lack of infrastructure to reclaim specific memory.
> 
> Details: Existing "Idle Page Tracking" allows tracking cold memory on
> a system but it becomes prohibitively expensive as the machine size
> grows. Also there is no way from the user space to reclaim a specific
> 'cold' page. I want to present our implementation of cold memory
> tracking and reclaim. The aim is to make it more generally beneficial
> to lot more users and upstream it.
> 

Why is this not partially addressed by tuning vm.watermark_scale_factor?
As for a specific cold page, why not mmap the page in question,
msync(MS_SYNC) and call madvise(MADV_DONTNEED)? It may not be perfect in
all cases admittedly.

-- 
Mel Gorman
SUSE Labs

