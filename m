Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2C4FC282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:15:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A71A21473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:15:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Wplr7vFt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A71A21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8A28E0002; Tue, 29 Jan 2019 17:15:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 187A98E0001; Tue, 29 Jan 2019 17:15:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 050BC8E0002; Tue, 29 Jan 2019 17:15:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id C82028E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:15:54 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id y4so3896056ybi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:15:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cjPKJoHf3Gll+qk80dZ1zwwaf8+ItgdBe9DjCPAWJDM=;
        b=W7MJDfMmLO+cLo+rAyt5AVI1x3SxBwY7y4yqh6NKBQ83b0pW7fXU/qj0lGGX4hLAkT
         AhF4AKaGQytWWF+pTH4TVQ/LZewPEabEii6+g8LuJS4uwnB+275LM+ofREP81WDxWEJw
         WS9INmB/z+/p64Jrivp6E8LT5Qrf6OROz7cY6RNOTuh0WBeqZBflerDm5wVzwmX3iGrb
         1HIKcjD9FE2xvCy39N0IauPpdJOrhJtu7ilCoImxFzaBF7yGd+jme+SrxC8I4qvSzP3G
         oKkHX7Rra6cG4C1yBU5ZEiFiHnHey2m7J2kmxfIL441nLDe1uQWZ9DGGWXFoe8wyZH7Q
         sMNg==
X-Gm-Message-State: AJcUukdcUVutUVF+Rfui/EZW2K5wSsiac9oRipzPjylWKYk9XxbuU99M
	G2DAbQGemxUBaIc+/jkQ4vR4pWMBlPWYEuU0czkxflM9aYQRZb0N0qAJquhNzgU9b2mzK6HHA/K
	spXLCsE6SXqrUZfCO7IRVK2ptUJe15yzkWbYiG3bfgRCmraldOvj0Vn+/fIOBgIdl7k85FZNVMp
	tOT16V/KYoKQsjGyrVqMINWWWWEecZhJWxRSSQ3ZgYAaZmlQ2cb58fvtR4jVllBtzSe9ZxYoLpl
	+KkIisuMU3NJf5AHg+xn3/hAnoI6n6EsC0ZpEow1jbFyG5581ZSSxcl7+iknumtmj5yDWYixt5r
	12ZrQtGDxJuxOPTVHn+9tRYvl8Te0aFe5VhnKh3pg87IyuZrCbR7N2F5PCuzTaIJisFoaw7ppTA
	4
X-Received: by 2002:a25:1407:: with SMTP id 7mr26048186ybu.33.1548800154405;
        Tue, 29 Jan 2019 14:15:54 -0800 (PST)
X-Received: by 2002:a25:1407:: with SMTP id 7mr26048156ybu.33.1548800153840;
        Tue, 29 Jan 2019 14:15:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548800153; cv=none;
        d=google.com; s=arc-20160816;
        b=QyFqfYoOW1XsmXttW0BbWgl6HrlEVXn7pTvRfEHJ8VWdjCYw//S+1pD0du38i0lRAL
         Sp45U3MVJLaDjkI0K0bzAOIs6GEsL5KcNdTUdhIrpVBPfoKgY2YEZWwd3ZbeDqUC4qpY
         OB3A/XV02Cfvzsl5zZDJ0nYJtZtRgmMmHXIoKR3KkisQgxaBXqBkR0L+MGeIHlXy3zYm
         PDooGQm+FTiOjxqIkhesq/wekoSEwvGzY3jGRx5EZ+pJmaUv/smCddZQ4yESCCxaZVpx
         tpZCuvYZvD31XGY4g4cj9BY/Q0urnDeO+fuIRFATSkfY92G8LajSJ9fZzNmcUhLm7yLc
         2Pwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cjPKJoHf3Gll+qk80dZ1zwwaf8+ItgdBe9DjCPAWJDM=;
        b=Trdc7LZsBw6TWUslKdj5gJrIjXEuy4b5zO4wi01+ueUBUGFwwFxpv2Swl+VpXyoFth
         stSE3hNC6PJRC9/T5NJibCtNVI+0TndNslHEy9W7S0WJumWFcQGyirONi9BO3Cazd/hR
         W1+3SvjeL9REb422rp+8r8j4BNqCted7Tuzzu/9G2/qAEURxwyCLH58CCDQdSao5W374
         t43BxWIFiKxtM9jBvGyLEKU3KfwD/ExcVVDTX4kgLj78MxTOY5JEZmzul2aPrT8VQEYG
         95hI16ajRqJKSEMo2GLK6/xxdgtMs09IAEiW/kcDyY3OiqucTAxDylgUBF9iFmdEntd7
         FQqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Wplr7vFt;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor6549693ywl.47.2019.01.29.14.15.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 14:15:51 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Wplr7vFt;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cjPKJoHf3Gll+qk80dZ1zwwaf8+ItgdBe9DjCPAWJDM=;
        b=Wplr7vFthNztMxNfahA1bdj2lR3+YAdLQRgxzerOl/TRr5R4rFJx8TUrvIk1v7GEmQ
         kW80/oYXICrRj09V7xe49KhmG2HZE1rJdek1rUmiqrM2TA1ik6ZtsJgqvXoDfbFUOR+S
         r4jYBxwP6P+szzZp1EYHRu4AAGuOv48jtQZkBrJIuIK+HpL2oLgfyUT6VPMjGkKDonHS
         muByxxO7QtKKoPg2xVphTkV4PvV79xkf5ySxjt/21cxk5LPq3n5eJ1Ke3iNPGFjjCCDn
         eVLHYSC/VtVDEYZMxvnvbWN0zOjJl29ex2JcIHoqtd4k3gYMyhNO+XXv3bD3rnJ2e43X
         LLtA==
X-Google-Smtp-Source: ALg8bN7irhuyfL8ClWcmZz429auZ4MvffBQRSq6hSXFkHXRmgB0027WWy+O8lD2sUt1XagmxX0AEHg==
X-Received: by 2002:a81:1282:: with SMTP id 124mr27709051yws.154.1548800151050;
        Tue, 29 Jan 2019 14:15:51 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:1d25])
        by smtp.gmail.com with ESMTPSA id e189sm14009152ywc.101.2019.01.29.14.15.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 14:15:50 -0800 (PST)
Date: Tue, 29 Jan 2019 17:15:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: Expose THP events on a per-memcg basis
Message-ID: <20190129221549.GA13066@cmpxchg.org>
References: <20190129205852.GA7310@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129205852.GA7310@chrisdown.name>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 03:58:52PM -0500, Chris Down wrote:
> Currently THP allocation events data is fairly opaque, since you can
> only get it system-wide. This patch makes it easier to reason about
> transparent hugepage behaviour on a per-memcg basis.
> 
> For anonymous THP-backed pages, we already have MEMCG_RSS_HUGE in v1,
> which is used for v1's rss_huge [sic]. This is reused here as it's
> fairly involved to untangle NR_ANON_THPS right now to make it
> per-memcg, since right now some of this is delegated to rmap before we
> have any memcg actually assigned to the page. It's a good idea to rework
> that, but let's leave untangling THP allocation for a future patch.
>
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Looks good to me. It's useful to know if a cgroup is getting the THP
coverage and allocation policy it's asking for.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

The fallback numbers could be useful as well, but they're tricky to
obtain as there isn't an obvious memcg context. We can do them later.

