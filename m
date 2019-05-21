Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21057C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB6AD21783
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:06:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="U9IxRev8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB6AD21783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AA186B0006; Tue, 21 May 2019 04:06:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65AC56B0007; Tue, 21 May 2019 04:06:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 549356B0008; Tue, 21 May 2019 04:06:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC996B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:06:38 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c54so16558033qtc.14
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:06:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JNAOtEoAZMPZZoa5GUaVYIK7Z6bfPkstoCwpa4KLdsU=;
        b=bAN70fp+8XsbwHYgQ5J9qjvn2x9CZLjf01UKN2rjKcCtLEG555BwmDD6JTnPgyPu8E
         mz9BaLE6NodW45wQtVRQ5g2WLdHYWVgYbCjay5C+YpIu5da/w8bZqroXwawHc09SK0lE
         v7VPn70T3bQA5abjqky/I/2jGoqRGt+6mgNH+zibvBMkIMGJkUXGqLI01LoXKfVuPeWm
         INYzkyAqyt2ESp9nsiGiFujJ0muXJf2BlUpyOw6IkQRzM6oMDyR0p44MchEaSKym/EMn
         rJd5sz0FDRxYLwA9mFAOw3tbv1feolPMGMzqo1KvH14I5v4tIpOEZzpQOqltW0dfnNAi
         pDog==
X-Gm-Message-State: APjAAAX27hKIDIfSfUh+sYpnAttAMq5xu2TNr8LVf1U01tEb7mX3V4lo
	cuGvZUMAULoav3bGvZXqY/9qd0JW9ZZvZVNM65wSP2xYYMG8prsTjmLS33HTM6Dz3Ucw/4Oo20w
	xNjH7IgCs89kXvjOf7Kinq8LosyhfU9QMcsOhaLK75GdzJn8IxQDARD+7g5p6W0cY2g==
X-Received: by 2002:a37:a707:: with SMTP id q7mr28638180qke.74.1558425998013;
        Tue, 21 May 2019 01:06:38 -0700 (PDT)
X-Received: by 2002:a37:a707:: with SMTP id q7mr28638151qke.74.1558425997566;
        Tue, 21 May 2019 01:06:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558425997; cv=none;
        d=google.com; s=arc-20160816;
        b=WvXjCvqi4/QxolpMvNXma75DkGSP1UKuTM3CZHQGKO41Ep+DkFLjIu/WW+TLTh5qxO
         Hw1QO/AhOdDU2xYjtTGvUNrLz6eNxuEZmNyymodZCj7VMrQAdwU/2K89YScHiolr+H1C
         lbAyW0IMlxku7GzD+bJKK92NyCKT9wgmZqfWFN8JKiqz9nhDRQGuEcdah7AKY+YLp7mR
         pbbQpLHMJV2UO6nxZ2tLuH5fQvdhaF1utKJgwe5N/nhTW9kGi+ra4Ie9Rm6u9nPOhO8K
         fur5uPyMZBB/faLKOfa7wK9YVLKmkV0aJJNExT90ZI8fQK3xjlxOW9MUdmDCL99CE2Ol
         IPsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JNAOtEoAZMPZZoa5GUaVYIK7Z6bfPkstoCwpa4KLdsU=;
        b=UzRMxkQqpIZ5mpoCY4SzVxtvyAJNQCD5zcG/sl04tTCU8Y9kX+yYDpbWKl898CxX4k
         xw2h4GiQEvbym8T6E+5OitYPFzsrLuy2m3TG2Qn/sZPlfruHLw3R0X4yj4rveZQCaHuI
         PVpJ9SsZRWsVsvLqkzk6huXQe+F1yeP5XxXblVJlU3z7khbO0+pwZcPWR7HeNp75wMeK
         q8QM7GzZFtIK1vLuYkHUBxcwkbGy0l4h+7JF7AskIWGj+ZC2h5o7iTPGM7MZYmdlQJea
         DQUeCbIucFu1uRGlxQzzasDXl/YBzZOwcA/Ph1mwFzGJk6Whcw5BTApmjB5OWhJOH380
         AxOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=U9IxRev8;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l39sor15415778qte.43.2019.05.21.01.06.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 01:06:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=U9IxRev8;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JNAOtEoAZMPZZoa5GUaVYIK7Z6bfPkstoCwpa4KLdsU=;
        b=U9IxRev8oSId9mHKIJv+d53QN59t1EllDgBux00QyjPdIWkW2pSV1eNS+pFg/Brcbs
         f5CpZdM7uH2Ks16A2L3DaM9kpzVHfSqmYBXQBtsnokuaksF2dwTcEIRL3e6wLKhL6lGn
         QPhNyXJb0HX9RgbbFd3OrOYHR06mmX5Aw1iIw=
X-Google-Smtp-Source: APXvYqz9hTNmVrZyrR1MFTVtToaRak51rm3XYKvAnie36nNwGE2XxgXwPcxAHngcippuPrEfmIUlT8qgLefYJeW3SJE=
X-Received: by 2002:ac8:2907:: with SMTP id y7mr32599676qty.278.1558425997177;
 Tue, 21 May 2019 01:06:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190520044951.248096-1-drinkcat@chromium.org> <201905211524.RpQYbGWw%lkp@intel.com>
In-Reply-To: <201905211524.RpQYbGWw%lkp@intel.com>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Tue, 21 May 2019 16:06:26 +0800
Message-ID: <CANMq1KDT1WpPksLw5M0OyujF2XnSM0F7gkhWLi4VAa6je48qsw@mail.gmail.com>
Subject: Re: [PATCH] mm/failslab: By default, do not fail allocations with
 direct reclaim only
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, 
	David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, 
	Akinobu Mita <akinobu.mita@gmail.com>, Pekka Enberg <penberg@kernel.org>, 
	Mel Gorman <mgorman@techsingularity.net>, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 4:01 PM kbuild test robot <lkp@intel.com> wrote:
> sparse warnings: (new ones prefixed by >>)
>
> >> mm/failslab.c:27:26: sparse: sparse: restricted gfp_t degrades to integer
>     26          if (failslab.ignore_gfp_reclaim &&
>   > 27                          (gfpflags & ___GFP_DIRECT_RECLAIM))

That was for v1, fixed in v2 already.

