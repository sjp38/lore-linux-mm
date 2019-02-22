Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36979C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 16:19:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E351220700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 16:19:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="RUnN8r6q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E351220700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B13C8E011B; Fri, 22 Feb 2019 11:19:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 762428E0109; Fri, 22 Feb 2019 11:19:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64FBF8E011B; Fri, 22 Feb 2019 11:19:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3888E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:19:48 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id r8so1660328ywh.10
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:19:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=p/eSOvpEPOdnBZfZTBhWwFR1RxWxC5GEtCoFlgWry3E=;
        b=Ntl0lzkf1ggJW1O4u1IiTwizU057UOvNCqMo7sNADWXYdTqfdNbiy07UgWUC8ksCM8
         lQZiFbDg9v2JMuUfNz5qkKQRj6M4Evn4LOXxW2fcSwKwIhYoB7T4eejlXCVmVH0o3zzs
         s+Yj8ifaK173Vj2H/SUR5WXr8AlvNWlUzcpiYyowG8/u0geQSYlyVDIRoy5g61+acLWL
         /UQX27cHhMXHA3c9Nu6cYljH+02yx2R0kiOSFbEfnP20svH2P+VKLUFAaWEbB9j8z8cW
         Zlu/HOqu/85ncbl7FsbHkTVq7q7BlG+GPyIyZE7sGTAlpGGHzuqQRXnpPTvzvdrH0MEX
         A81w==
X-Gm-Message-State: AHQUAubMn/v2b+VFV4zKuSXio+HmMelMDJqpOd9jv3HLuhY7sO4TZkOk
	WR1rsZJ00AYnB/RL/nJHyVfsFueCulXsvAx3HbGZAJJEW3tbYsi7j6IUNGzJkyQVRbT4Ih+sVqk
	8FpN7t6NVOSZrFW/0U0yNOKmRGjtEYHGnmhLea0LOo2lLWKgFk/pAMGDaQqmH/0nRvjdUjXJTYH
	WtvyuCpHT26e3Nvx+xrr10cXGmHXzld+Snt7uln/9x4+JBTmPrmjNJpXFmEs9lgB/jQZQX8S8Mx
	WQ0uvJWgqRPdSy35tpktddLM7wbmfhtunvTKdfr65fxl3V8sm46PnV3CX18katg5JjNpohGBW2o
	5N0OmbWhQFnubyt+0mYTHfstVRHjPN2W26y5Z+0aVK3kKF4PwKAnBQHgFkE/s+i/652gXG6Rp7o
	E
X-Received: by 2002:a25:c886:: with SMTP id y128mr4057878ybf.250.1550852387887;
        Fri, 22 Feb 2019 08:19:47 -0800 (PST)
X-Received: by 2002:a25:c886:: with SMTP id y128mr4057812ybf.250.1550852386969;
        Fri, 22 Feb 2019 08:19:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550852386; cv=none;
        d=google.com; s=arc-20160816;
        b=rbWGVEtdgZZNoFxaPYXGbJwTAfef7t7fop2mICSP4gA8oNzp/E3+iTScFwpTTmm4c7
         k1D33wmDtjoGYwR9OEpwpnGIapIkU03zw51boMgms8vQDRohYEOoGD9DDh+T3EZ2Ggt5
         w31fwCHKUasDmLQImTEMk3Ugj1kklu+ja9Sh1iaFx8XR8EpZqXWYtih8jLJuc43g+IzB
         RNEygkG31a+Je4ENFMLYT3BUZxM95iSALeai0Dz9NChaF3JToLL0+NLJFBCnrjQvePTH
         n7wi21TVlCNuaMCoRmbfSnq5B/6dJh/GUnFUITmH5dAKc5uJ9/zqgBUXoOG6i+i4IsrE
         ObxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=p/eSOvpEPOdnBZfZTBhWwFR1RxWxC5GEtCoFlgWry3E=;
        b=Gw3GavlBUildMqkMzKXS8OdiMGA3Fn2kKWvZxnugpU26wD5ifQRVfM+UQc2lD3QBJb
         0qR5yJp1wtViPpGALry5uRB/K4gYMTvJEbIkyNOrsz65NPJ/NCRElyqlok/EEMS9CgMK
         WoTYuGD5BhKHulncKTZWEx8XjD14TGewoZzcaMEWn82oGxsIk0zyus17T/b95OJU/jJ8
         +jBmkTzIVbCIsOvl36qKnjB/WdtPJK0NGGSZ6qL6KlUeQb0T3iZcwZCWeV4bHV9Yr7bO
         7kLQN6shglGqaesgsZT2RXn9Wb6EErtvpK7Stm8ID/K+moFGPMvpnr+6OzCTBCQy9czT
         mdlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=RUnN8r6q;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 128sor931748ybm.149.2019.02.22.08.19.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 08:19:44 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=RUnN8r6q;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=p/eSOvpEPOdnBZfZTBhWwFR1RxWxC5GEtCoFlgWry3E=;
        b=RUnN8r6qzpBx09mG1/K52QKdmWaNXQKvvE84vAqjXIG/ZVaVcq+f95dgkj4qB8ww1O
         inRD9jCX/m2epxKCQbp3T9kd7YA+hm1MLH0waZGi9Ah2KVreVUs9Vt0o1nGGZu6S0eNE
         2uoUMjRjeDl7cf86+GgxER3fdSGS8eW4jheYlCKyRL/MSnFjGKsQCBXhz33N1cl0NkF0
         OYPlWuIvyhdjuYjdcmrXhFKHzi0idXa5EkaWv0sDKA0bgXep1vJbWRyMVAvDZbmOpk+n
         JP/CHme3+owY86MfPRvgpB5sR9EPLLhEk/58YkhjOfPcfe+QWiHYI6GX5JMMfqaqQQ3e
         TDvQ==
X-Google-Smtp-Source: AHgI3Iaiq/NJn/9xzBub2fgaaUyU2LJQjR9GHmHHPQnoJWWBd+CAnW5eiv/igAntO8Mk8UxSIjD2wQ==
X-Received: by 2002:a25:1907:: with SMTP id 7mr4077408ybz.14.1550852384186;
        Fri, 22 Feb 2019 08:19:44 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::1:cd3d])
        by smtp.gmail.com with ESMTPSA id o4sm557182ywe.102.2019.02.22.08.19.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Feb 2019 08:19:43 -0800 (PST)
Date: Fri, 22 Feb 2019 11:19:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Junil Lee <junil0814.lee@lge.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	willy@infradead.org, pasha.tatashin@oracle.com,
	kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com,
	andreyknvl@google.com, arunks@codeaurora.org, keith.busch@intel.com,
	guro@fb.com, rientjes@google.com,
	penguin-kernel@i-love.sakura.ne.jp, shakeelb@google.com,
	yuzhoujian@didichuxing.com
Subject: Re: [PATCH] mm, oom: OOM killer use rss size without shmem
Message-ID: <20190222161942.GA12288@cmpxchg.org>
References: <1550810253-152925-1-git-send-email-junil0814.lee@lge.com>
 <20190222071001.GA10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222071001.GA10588@dhcp22.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 08:10:01AM +0100, Michal Hocko wrote:
> On Fri 22-02-19 13:37:33, Junil Lee wrote:
> > The oom killer use get_mm_rss() function to estimate how free memory
> > will be reclaimed when the oom killer select victim task.
> > 
> > However, the returned rss size by get_mm_rss() function was changed from
> > "mm, shmem: add internal shmem resident memory accounting" commit.
> > This commit makes the get_mm_rss() return size including SHMEM pages.
> 
> This was actually the case even before eca56ff906bdd because SHMEM was
> just accounted to MM_FILEPAGES so this commit hasn't changed much
> really.
> 
> Besides that we cannot really rule out SHMEM pages simply. They are
> backing MAP_ANON|MAP_SHARED which might be unmapped and freed during the
> oom victim exit. Moreover this is essentially the same as file backed
> pages or even MAP_PRIVATE|MAP_ANON pages. Bothe can be pinned by other
> processes e.g. via private pages via CoW mappings and file pages by
> filesystem or simply mlocked by another process. So this really gross
> evaluation will never be perfect. We would basically have to do exact
> calculation of the freeable memory of each process and that is just not
> feasible.
> 
> That being said, I do not think the patch is an improvement in that
> direction. It just turnes one fuzzy evaluation by another that even
> misses a lot of memory potentially.

You make good points.

I think it's also worth noting that while the OOM killer is ultimately
about freeing memory, the victim algorithm is not about finding the
*optimal* amount of memory to free, but to kill the thing that is most
likely to have put the system into trouble. We're not going for
killing the smallest tasks until we're barely back over the line and
operational again, but instead we're finding the biggest offender to
stop the most likely source of unsustainable allocations. That's why
our metric is called "badness score", and not "freeable" or similar.

So even if a good chunk of the biggest task are tmpfs pages that
aren't necessarily freed upon kill, from a heuristics POV it's still
the best candidate to kill.

