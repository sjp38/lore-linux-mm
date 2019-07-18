Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFEB8C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:22:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFA582184B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:22:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="jVzhwBA9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFA582184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B3E46B0003; Thu, 18 Jul 2019 17:22:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 464FB6B0006; Thu, 18 Jul 2019 17:22:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32CE26B0007; Thu, 18 Jul 2019 17:22:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F11346B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:22:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so17362584pfi.6
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:22:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DW+lj/GCQy9mAaX3q/xvSH9Pj0ics0t1Yarw2u9QXwE=;
        b=Bga9uGbP8IPHEpnFZj6beieEUMJkS3uhptAGHNGVCNyIbHc9qWGrErlXOvlT11V9jM
         cwuTPjM9JdwgOnd+UgzX6BNfMHQxzexyb6xsMiMr8+7bBjppjZROPaxvZ1x/pNqYg6SI
         JyubJiunaUAyOYA90xw20Z4p8SH7M7QRneu/RjrlZxIqRTKgo8mG21gGOs72aP5F1JXf
         TTEDlpcSxYJvtBGgUQDN1i24f+Ywi1thfLA09PiPvquv3wwnFEqYQN6QSkeKMARkL0ol
         rK518VsGz4p2NmeY1e9H+JIeiwjypd7uei28xOMtj59rQY2BZYM7DbnRQ5IykESFjUMW
         lbvg==
X-Gm-Message-State: APjAAAUYWso3EW1nr+YYkvONWGjvsA1eHddawJPTdWAehoqIH5uyKiuP
	lhesk2m8kVp+A0f8q+oraQt578dWuKPuMtLcLigVHc11ukYYH5PuPX/lQ4ZW7gOe3Qs2K3l6/jl
	mv45xe7gvR8CdXKHvHI7eOmv32lQ+DJ/LSO0HdMT8arrcu2phwXeKDuvv8nUMRgOtdg==
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr53419707pla.5.1563484924587;
        Thu, 18 Jul 2019 14:22:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2PvPXkBLFq387xc8Bg1YLb4syl8Lys34ZJ4U2rxkaLSlpysgSxcLJ+RtvRWyilQTEdP+o
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr53419660pla.5.1563484923946;
        Thu, 18 Jul 2019 14:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563484923; cv=none;
        d=google.com; s=arc-20160816;
        b=FySM7vj1cblmfNeB0DHKlRDjak/XpsSVGx0tf3ObTB5Rmib3UOJehHUVFo5Krq0p7B
         bkcwqwbNrWxIPJ2s4OkAxMY6dgu5rfjV3XhlpUdX1yj5P3pBY/nT4xiuRytARdU8p6au
         W2Wf09jBqqZJLZRd8pYaQT1+vJhwudVYDYDaDR2TxT+HN5ORpOqcjpqAvN+8aavoZDtM
         LfA1L3A0qR18ywiBUzATBlIc5mz/he+bfv08OtWS3ZcLJ6d3bXD8UQ2kZ+MpMgR3DPzx
         BGqTc0I2faXNb0tuzUZQ3SPFgudszin/dFWtuqw9ut1g9VqoafL9cn/V1JINLoGMY+ws
         +tKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DW+lj/GCQy9mAaX3q/xvSH9Pj0ics0t1Yarw2u9QXwE=;
        b=eTuGVl/YcF7GBx4apfpb+sG4qtb1QNjMnsGCcOHe7nKHW8h3vxdTv6UIKXl95FB2lP
         1l6BgnVsRvvFJXH8H1AoyTPACOqr2PnTBwTRjcdPUSzLj922XTdqo8MGe4ZxGwQGpVqX
         ICKtkanvgMpfeL8vsDRA3zjHL+wT1Y+aImrMyPhh0XqYASFpqA56kL6fF95ohj8Y55Fd
         SP3EY/qv0f21Pnzlo2eX5VQ41c+VV2/vUl/K+g2Q3LLkU+QrMpB3AmGYZfQ8Aav892/i
         WVjrRDNfNzzinBSuUbivJ/TbnOaavi45k4FpCzqilzDneylxjXYQVBeMVQYWyDVEzp8j
         6vxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jVzhwBA9;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 33si742691plk.225.2019.07.18.14.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 14:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jVzhwBA9;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6EDEC21019;
	Thu, 18 Jul 2019 21:22:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563484923;
	bh=picct2x5G7z5eN/bZQA7JUic4g6eKx+sam1kr/kt1rI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=jVzhwBA9+uq4iKWl+Y9YgA6z/5Wi0y+4pyKBZDxq7NUS86OWUpDBbqCQZU6nbYWVm
	 0UQJD6Dd9Umf/pnGl+wuCdlbSRp99cNmK6SID9Ki+c2WBzRvTgKFK9m84Iehb3VkJf
	 C3WBGg8pTTGn5Xf75DSlJV4zJA/sq4rbHpuxL84E=
Date: Thu, 18 Jul 2019 14:22:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: howaboutsynergy@protonmail.com
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka
 <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: compaction: Avoid 100% CPU usage during compaction
 when a task is killed
Message-Id: <20190718142203.22f4672a520a5394afd54fd7@linux-foundation.org>
In-Reply-To: <Wnnv8a76Tvw9MytP99VFfepO4X71QaFWTMyYNrCv1KvQrfDitFfdgbYvH8ibLZ9b1oe_dpPfDdQ1I2wwayzXkRJiYf1fnFOx6sC6udVFveE=@protonmail.com>
References: <20190718085708.GE24383@techsingularity.net>
	<Wnnv8a76Tvw9MytP99VFfepO4X71QaFWTMyYNrCv1KvQrfDitFfdgbYvH8ibLZ9b1oe_dpPfDdQ1I2wwayzXkRJiYf1fnFOx6sC6udVFveE=@protonmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2019 11:48:10 +0000 howaboutsynergy@protonmail.com wrote:

> > "howaboutsynergy" reported via kernel buzilla number 204165 that
> <SNIP>
> 
> > I haven't included a Reported-and-tested-by as the reporters real name
> > is unknown but this was caught and repaired due to their testing and
> > tracing. If they want a tag added then hopefully they'll say so before
> > this gets merged.
> >
> nope, don't want :)

I added them:

Reported-by: <howaboutsynergy@protonmail.com>
Tested-by: <howaboutsynergy@protonmail.com>

Having a contact email address is potentially useful.  I'd be more
concerned about anonymity if it involved an actual code modification.

And thanks for your persistence and assistance.

