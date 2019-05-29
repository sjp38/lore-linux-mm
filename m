Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4D82C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87615241C3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:08:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iCu9MPsy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87615241C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20FC66B026E; Wed, 29 May 2019 17:08:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BDE36B026F; Wed, 29 May 2019 17:08:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2CEA6B0270; Wed, 29 May 2019 17:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B72666B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:08:02 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w14so2398028plp.4
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=JDuSTehyNdkjsOxtouLoAdMdAueINAK3K8uBz+p0jwg=;
        b=K/kjEybXyUhCmqJ7OLj3i6Jixbg/nrwgce+Ve51KnARe1rroTa2B6ogWv3TzBKAjaM
         AjbwHoSdfhsgDRCEWvLsG7ujxYkfemy40Y0cyfRrjCokk2BwzgcmwDCGUkbiqKYbDC0N
         jH9AXGzGM+QUench8W5sGCnPT7YDLCNJ44T3xQ6SudYqkGHN3oIER5R3VGsyXmgeEvUf
         x4aDZiKiaIrHpvpQr5NnJAamMwDMR2nyjiRoGf5/fknhbbeAPEH3lML1oYzMpOW+6Hzx
         4V9BTkZXLfiMyfIRlGcrAtLYFxckDrIV6a1gqKLzqsXw6A/Kl1ytkd4GMuTcMD4Umo6B
         7rHQ==
X-Gm-Message-State: APjAAAVpTH+uCzQR+Tw/4MOyhBNhu0kDpqDWfOSroccLYMNe5egPW4Er
	6OSXvPg+qBsuptxGA793rgqCAu7f61re6tS/K3tSxsBQHfAKB9tv8ia0UDMZxqHLCtEACDROoKA
	2Et3HOasgaxuvdW3V1z/dSbrOYX8Lsr/VSKtS5Ouu2gcg3Wtjtm5UGj24SMusiUJPIg==
X-Received: by 2002:a63:9a52:: with SMTP id e18mr1581pgo.335.1559164082367;
        Wed, 29 May 2019 14:08:02 -0700 (PDT)
X-Received: by 2002:a63:9a52:: with SMTP id e18mr1542pgo.335.1559164081594;
        Wed, 29 May 2019 14:08:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559164081; cv=none;
        d=google.com; s=arc-20160816;
        b=BU5p+MJwebnrOzOIgDY+x9SdtwYTC8ACgxbAJjiA3q8TxaQGtepxPMk6xYHGkW1745
         WWjkZ1zdhzshdRN//lV0seWHza4xouILzxkDiW4xID6FCJhl9rFo5R/tcu/65Qgbg7D6
         x28RkckmkAOguc6tu7MIjMLUf5D3rSYb+AUv4qwR4YYRRKbIO6noSGNA5G2M+jpwKB7h
         qMJvtYv5ynPShvHYfs/PgkKlPzo4X2O23deF/X22ASNKfoRTEQtVCmUpfMbcmPzfN/i3
         ToHQrWUNlJroaNeeYS9A9IBIwPY2E/T/BmR1orck9BqIDJlOWWw525i7vxfe5rvPZTuk
         ASkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=JDuSTehyNdkjsOxtouLoAdMdAueINAK3K8uBz+p0jwg=;
        b=XwNKefyBln/6pjAWAuGQWhSLsy9k55hzItsbf3Q/keyXqXVxoSWBXrbryl76EA8A1b
         LrZm0S9RGGMEPt+8lSz/T8RsvrXB6xu+IR25FbvRiu45Sy3WqV1+h41qBt8fXlUsEGOL
         Ip56qG8pvIn97buvjYyh/O14bt0/s84V0Yj7Lm6oUxSIou3413bYftxXhIbjkhdsTHdI
         WmYFjWhGz3oi0+7a2cF/yaTIEmzfpBAXW3oIuXywxTida/rgGVo7m/LrIms9chY5GDll
         8aiOzgkniwoYjQjLnPG4FjDAEkCm2uAGEURT5CJ75qq6WzGKTeKV9y4F8TbH3kOHMc2e
         xMTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iCu9MPsy;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4sor860945pfa.60.2019.05.29.14.08.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 14:08:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iCu9MPsy;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=JDuSTehyNdkjsOxtouLoAdMdAueINAK3K8uBz+p0jwg=;
        b=iCu9MPsyqSyo52dk3bz2YcMkQmNZYRBnUvKfoC/4nlsyxR2kImqL5WSQ/tyUgbQGS5
         tWRxoAuFxGICRlXINV3c2tZaoNnVTDCu3AQWUlvkm0C+fQdRbz4FGqR1DvMkNENEbQCo
         4mLnFfcmw7g7RiFYFM3uP/L9kskO6vNvXIOsYcoEhUccyXOhOgTv1ZIoqlt4GkhouIyt
         NoatEjQ0v842w1+LfUE6qcm/wVA+RI1gtWZSmg7y9eYS/xmE8gKbr0HdmnWyXfEA8pYA
         D2roDVoI+GkFybcqvS37aJdhvvXWEunPHYJZmGU1JBmPeR7muDxlo4h6jHkWn7gz9wTu
         D19Q==
X-Google-Smtp-Source: APXvYqz7P8HgjdZeBHIm1rggdqtNB5srYYVApd3MRmDP73Wpy18Y0LXtAZVWv+Kw+t04RSc4FWh44w==
X-Received: by 2002:a62:e303:: with SMTP id g3mr150555799pfh.220.1559164080811;
        Wed, 29 May 2019 14:08:00 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 25sm574143pfp.76.2019.05.29.14.07.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 14:07:58 -0700 (PDT)
Date: Wed, 29 May 2019 14:07:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com, 
    kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/3] Make deferred split shrinker memcg aware
In-Reply-To: <2e23bd8c-6120-5a86-9e9e-ab43b02ce150@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1905291402360.242480@chino.kir.corp.google.com>
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com> <alpine.DEB.2.21.1905281817090.86034@chino.kir.corp.google.com> <2e23bd8c-6120-5a86-9e9e-ab43b02ce150@linux.alibaba.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019, Yang Shi wrote:

> > Right, we've also encountered this.  I talked to Kirill about it a week or
> > so ago where the suggestion was to split all compound pages on the
> > deferred split queues under the presence of even memory pressure.
> > 
> > That breaks cgroup isolation and perhaps unfairly penalizes workloads that
> > are running attached to other memcg hierarchies that are not under
> > pressure because their compound pages are now split as a side effect.
> > There is a benefit to keeping these compound pages around while not under
> > memory pressure if all pages are subsequently mapped again.
> 
> Yes, I do agree. I tried other approaches too, it sounds making deferred split
> queue per memcg is the optimal one.
> 

The approach we went with were to track the actual counts of compound 
pages on the deferred split queue for each pgdat for each memcg and then 
invoke the shrinker for memcg reclaim and iterate those not charged to the 
hierarchy under reclaim.  That's suboptimal and was a stop gap measure 
under time pressure: it's refreshing to see the optimal method being 
pursued, thanks!

> > I'm curious if your internal applications team is also asking for
> > statistics on how much memory can be freed if the deferred split queues
> > can be shrunk?  We have applications that monitor their own memory usage
> 
> No, but this reminds me. The THPs on deferred split queue should be accounted
> into available memory too.
> 

Right, and we have also seen this for users of MADV_FREE that have both an 
increased rss and memcg usage that don't realize that the memory is freed 
under pressure.  I'm thinking that we need some kind of MemAvailable for 
memcg hierarchies to be the authoritative source of what can be reclaimed 
under pressure.

> > through memcg stats or usage and proactively try to reduce that usage when
> > it is growing too large.  The deferred split queues have significantly
> > increased both memcg usage and rss when they've upgraded kernels.
> > 
> > How are your applications monitoring how much memory from deferred split
> > queues can be freed on memory pressure?  Any thoughts on providing it as a
> > memcg stat?
> 
> I don't think they have such monitor. I saw rss_huge is abormal in memcg stat
> even after the application is killed by oom, so I realized the deferred split
> queue may play a role here.
> 

Exactly the same in my case :)  We were likely looking at the exact same 
issue at the same time.

> The memcg stat doesn't have counters for available memory as global vmstat. It
> may be better to have such statistics, or extending reclaimable "slab" to
> shrinkable/reclaimable "memory".
> 

Have you considered following how NR_ANON_MAPPED is tracked for each pgdat 
and using that as an indicator of when the modify a memcg stat to track 
the amount of memory on a compound page?  I think this would be necessary 
for userspace to know what their true memory usage is.

