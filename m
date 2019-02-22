Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D604FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93A2A2070B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:58:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="A2Sft/WQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A2A2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 459BA8E0125; Fri, 22 Feb 2019 12:58:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 430398E0123; Fri, 22 Feb 2019 12:58:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31F7A8E0125; Fri, 22 Feb 2019 12:58:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04ED08E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:58:53 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id h73so1903461ybg.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:58:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TOEcho+GLt6cXpqefD54aAURhA+BCLd60PBO2YlEQPE=;
        b=e9NMPSbgoznm3GkdCI1W4gX+5HpYEKMrd4F4NC4EDeIyiLvWmdXWinh98KNzKqB6Nr
         KW5OhErk7amDTgm8po55Cfs0aHdb6SKu8O1+V8yKTSmf77COToMSYpPeIwyvWhEpj0OQ
         OzHUYWDsomcaobOn5TjWXAuL4wGBlrYeJNTaV46PdRxu609fdd9ETHs4VV0CjvfPAonB
         WFtaIsYjCKebG8S0fC95XnewRevH77JYWz4pWSxcdXQCET2D+6LmGOWTGtV+KRDL91M3
         P6N0ldx4rou8D6/pniK89JOq7rdMdA4+AX0kfXX71UQexYReU1Fva0OCmn06w+jvKBJd
         pwbA==
X-Gm-Message-State: AHQUAuYVxsIc0GFEIRL/eQrrtAqutaxdnKn2/sIwlOVDxpbmQktMKwLM
	Qqqi/8p6KZsYNuLv5dL4vGwYsd6ljMv1caMPYydquB2ASys+R7iXHqjacwGCfr7TVbGoSj9Fv22
	pMWSul78rRjVjMbNwt3/9YZ2T4WPHnzfRrfHaaswG39eKfstQTch82WTGwYHpSZVGPG6+P0y/73
	rK37Colt2EY/Ai2b0nLTN6bawRwlUYqynFMvw7HPsqsk26AhkeVtn7I30jt5S7aBG0AlP4L3Soc
	VEnFyHrsj/3TetzgSkJrX2g2ri+MWhocHuFZdA/Behi+mbEk0s9FeqlfpZOSiwJg1QuoKtnjlJL
	HldyHbRzY19tpkN3j4NVH2s7/HiADtBWdv79SFCligvEgau+MigtBPqc/irrxzikLDmYf/zuIyy
	X
X-Received: by 2002:a25:2c2:: with SMTP id 185mr4615155ybc.322.1550858332649;
        Fri, 22 Feb 2019 09:58:52 -0800 (PST)
X-Received: by 2002:a25:2c2:: with SMTP id 185mr4615100ybc.322.1550858331603;
        Fri, 22 Feb 2019 09:58:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550858331; cv=none;
        d=google.com; s=arc-20160816;
        b=Hy5X3RszbNKSao7fCyjIY40lG1HaSbPxpQELFHOR0bwLv6KiP3cSNG8PxdZYskymXC
         1YMORQA0+ULg1mFDpEobsM4X8hLmF1PUqk6LFz+aZJQ9nIwA3+72sKqXcX6YblqAZO9m
         Jk+g7aSepYXXm8IhT2eZ+DhQ9BoAdisOHmkah9pYZCioY3/fHuFhCPR/Z7gDW7oJbsOK
         jd9XyP/d2SHU9BnIZnZ+K8Lys47HHEwUhQ70+QL6/Gbkfsm/xEru82YScve9l2uOn9Hw
         3dYY9uocpjb73TL0usSpgbNnEesKmN2ZNcRj4cpdkjm1U8iX5fTBH6g5XWHKEdT9cAuK
         OfJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TOEcho+GLt6cXpqefD54aAURhA+BCLd60PBO2YlEQPE=;
        b=uqi+8MqZb8rpwI9XoNED/oNxoOZr8oXNLdLUsqnj8t3kLtLjFCwUOg8PEllyK9NNTL
         iBOOu2Hbz9ilIxV9HqH2pWCvjhzSZSSeEglLCbAMwQm0/BhZoqlS4QEEWQU1L+X8d6ec
         wNMUK9IG4mTUAF3KmtjCHfFZlx0tVB4jeAXwbVBmqcbvZJQsUv/v4afbRI8++BJdfzO/
         9TwziQUnYhBQuVJ6sz+RZ/XJ2X4Mh7Wzb5hq+zP+J4gqQkHVpBPoUejHR0DMAblse7iF
         0woutfDjyqY6afeui/N+oTA95Wa8B8DkNLVe7d6QTyWUm1DpVFomtH+rXqxwXHwIX7YC
         NkIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="A2Sft/WQ";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l73sor427747ywc.64.2019.02.22.09.58.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 09:58:47 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="A2Sft/WQ";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TOEcho+GLt6cXpqefD54aAURhA+BCLd60PBO2YlEQPE=;
        b=A2Sft/WQmBlkr3es6WDbt1pSVeOb0argQnx9eefEZjBTB3xLC7GgQhNtSlJfskM1Fg
         R37WAh6H/HoHlaRlOnRQTO1uSyFx3seaP4cOLC8D3xGOLQij6ZyOTKmhRYuv88hg0ijg
         7xm7HcZJ6jcPZSmjp9oMEOtLNQQaCZ5asKyFQ2KZ9Wje3kpjOvaSVYcURl5Z21adry3/
         Ebv9NTRH2x97k/zjOmIBXlaO+9sDzWAV79QtZTjqciCnulz1ytOmQr2ncbMiS7XR1lVl
         ivnzGJeML4X2ulCkFKzGLfFJuvDnY7+MHPwhYpTTW2gf3t55yWuncKSTg+sxu8DUxHT8
         EWNg==
X-Google-Smtp-Source: AHgI3IYEN0aOcdA52dHlcHW9Ome9v1T1GoRkWaUzDvIC+WxLj2bUrzb4Mk7QLwWGS88W2T4xf7csFg==
X-Received: by 2002:a81:a4d3:: with SMTP id b202mr4322592ywh.83.1550858326785;
        Fri, 22 Feb 2019 09:58:46 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::1:cd3d])
        by smtp.gmail.com with ESMTPSA id n67sm2086197ywn.1.2019.02.22.09.58.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Feb 2019 09:58:45 -0800 (PST)
Date: Fri, 22 Feb 2019 12:58:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/5] mm/workingset: remove unused @mapping argument in
 workingset_eviction()
Message-ID: <20190222175844.GA15440@cmpxchg.org>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222174337.26390-1-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 08:43:33PM +0300, Andrey Ryabinin wrote:
> workingset_eviction() doesn't use and never did use the @mapping argument.
> Remove it.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

