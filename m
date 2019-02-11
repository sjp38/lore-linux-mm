Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E08CAC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:55:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DF4F21B69
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:55:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="KSmBfVOt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DF4F21B69
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FE5E8E0132; Mon, 11 Feb 2019 13:55:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AF2B8E012D; Mon, 11 Feb 2019 13:55:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19E9B8E0132; Mon, 11 Feb 2019 13:55:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id E63E48E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:55:38 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id l14so8300271ybq.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:55:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/fwPQA3qU7Aku9UVL4Xj6OeW7KvutLJujKV6PtXhaFY=;
        b=VQT5hSTd8pNijoD82qAvOyKy74EmvKJpDKQ3fpAe5SvlVVjlXHqaGBvgMFBiFWErMc
         e4dD9dNvLHotEmqc5tnpvf5MZQwl6Wy5JnMNL5RjXIx1eCZi0Pwy/rj3/FpvM8uAuYWq
         pa+DDlLzGxjFDeqyFfF0Iyfn6agIq4Txno0Onqp1Ot8ZKu9QQHW4/0fsbKGEoGtFe97b
         vwLMkVe3hbqSaPvG2ptjFyo/hTJRQkMhxTwjmwKOVJlErsFdUbdma2ulGK2tKHLPmcaC
         L3tGSNdoVApTLZzoqoqe8xX8IayNb/G3NfWA6W2z6N2GydYMUSXi0zDlkzgbQwVvxjCi
         tCEg==
X-Gm-Message-State: AHQUAuZie8jR91aLluxN6PheKfW3DqFNQpXPIh2d7kvxTJPmmZY/kVvo
	kdMCA5g9f9+bqd1F7/3uL25l2e7Kh2FNjUolfDIWmR1tK+22HMKgH9WeDasA8G6RsKHwWsYfSzs
	bsb+ZhYXbGE8Q2t/Ghp1UN37E/L9BvwAb2WYoPPnZKKAfiq9qtT3tL59tKbDb2TMUaTrMt9jAxU
	0j7RcXV1YnaLYuL/j8lFJFp/A3wdOATxv3v3r22j8K6HZOuV5Hwk9GN9brPXfIF64J0GJL1qFzP
	A/+yMcWbp33CqliP82FkI9KChA7DPmFgq+LR0oU4iTTr6yuam+ZKYFbCSSTFfCIEB1Ezkmne8p3
	H24ci8TYgoBr7Md+fKe4KJqPzyvFapnbTPnIStNdCKcr+nlHOvxh4MnAkyPlx/PfjTBYLJULH1S
	g
X-Received: by 2002:a81:2982:: with SMTP id p124mr13904270ywp.273.1549911338668;
        Mon, 11 Feb 2019 10:55:38 -0800 (PST)
X-Received: by 2002:a81:2982:: with SMTP id p124mr13904238ywp.273.1549911338103;
        Mon, 11 Feb 2019 10:55:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911338; cv=none;
        d=google.com; s=arc-20160816;
        b=yDmnh2IushQuSDIzkdyWxf8abTx3ohMGrUEca5MZMoNGNbgQkEN9gDnl/WR9kDLg0m
         5LYzhWUeZeoeww+7DP+GDGBHcS27/0nu8nP7xjvQWTGNC/keo6SYiEzOVJ6Io9PceWpB
         6r3c+Bz1K+DBmU0X9fPlRakaIRiXMxaW4YTRjhDkijiePIWblpqoPWZVXPokS/Gniq+e
         fHh3WrBEkpnSMKjnLMVmyH2j9BHzqUCPpyFuO7jVOeV/hd5ZkX45TSA+DPFTs1DCcmao
         Bux3HCxBZLaIhFI/AQBLGh+gUTVeM87Z5tc5QgpUN7T0heo6Dq7ckfYvcaReZo8BjEBD
         RvDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/fwPQA3qU7Aku9UVL4Xj6OeW7KvutLJujKV6PtXhaFY=;
        b=myEHXTw3s5Ak92wWR1gN8oEZTuFK4p7YX/dUfnTNuP2AkQSzfDWNGWO9xeVxqDcCNT
         9Jy+LmVmtFe0y409Mh07WPX0G+PjG7Y8A+8lGx7wVxNPM6DtZA3QFmd+fU98GYon9ZR6
         FlQWQSUv4W4gt0VS2dxXZNzSev3mnPp8ihZICFrijrhFEJnYxhYY11yS8e+t8KMk6BtT
         WIMjIN8o1/3cQaq86dngxQ976KywIA9Bib9J4sKCKTOXNnINa7E/+lpS6leZGne+J05b
         bnPyWQpucQuVeqPfoF97KFhxyps4pcd5pFuYUwicHXYUxD60bioI4zpVj8sgm0VaQOSB
         083A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=KSmBfVOt;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 124sor4805596ybo.65.2019.02.11.10.55.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:55:37 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=KSmBfVOt;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/fwPQA3qU7Aku9UVL4Xj6OeW7KvutLJujKV6PtXhaFY=;
        b=KSmBfVOt//tembuNf6qv9MiwaTLSt+/d0XxrB6YxhFnrNj7Jqys5VcAp3OPQumEVZ/
         MqNLDSVZYNG1PxLrbZZsbpJcxOkt9kXzOTjxqhq2+IImeP4X2Y3sSeX/0PmGithDGw0F
         uMHmyy7dkXFRies/O/3nElxwMqp5pI5QaiAimssP6jMzVS5oq8XEHNa/fV0whvCn3yoG
         hX02Fy688V5oZdTAGvqfw7ARKSHPmaVRYE46nvOxhHfp1AMiewmMN+7RRMU5WlkLHTvj
         10aFXwRq0vbyIvETLdDorc5HSbf9fgvWlID477XFlspaTWkVLjUt97ImjVTjHCJpeZ6j
         mrmQ==
X-Google-Smtp-Source: AHgI3IaMY21YYwpqjIFAOQ6KEJBW67d3KzImvcjP2lWzxm0+49GO/cYAkDaX1p9rA643uL+lN7i1lA==
X-Received: by 2002:a25:8e0c:: with SMTP id p12mr30114498ybl.3.1549911337759;
        Mon, 11 Feb 2019 10:55:37 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6e5])
        by smtp.gmail.com with ESMTPSA id 77sm4071530ywr.19.2019.02.11.10.55.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 10:55:36 -0800 (PST)
Date: Mon, 11 Feb 2019 13:55:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH v2 1/2] mm: Rename ambiguously named memory.stat counters
 and functions
Message-ID: <20190211185535.GB13953@cmpxchg.org>
References: <20190123223144.GA10798@chrisdown.name>
 <20190208224319.GA23801@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208224319.GA23801@chrisdown.name>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 10:43:19PM +0000, Chris Down wrote:
> I spent literally an hour trying to work out why an earlier version of
> my memory.events aggregation code doesn't work properly, only to find
> out I was calling memcg->events instead of memcg->memory_events, which
> is fairly confusing.
> 
> This naming seems in need of reworking, so make it harder to do the
> wrong thing by using vmevents instead of events, which makes it more
> clear that these are vm counters rather than memcg-specific counters.
> 
> There are also a few other inconsistent names in both the percpu and
> aggregated structs, so these are all cleaned up to be more coherent and
> easy to understand.
> 
> This commit contains code cleanup only: there are no logic changes.
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

