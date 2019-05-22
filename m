Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2D13C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ADC12189D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:59:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zr8gMdgg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ADC12189D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04FAE6B0003; Wed, 22 May 2019 17:59:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0012F6B0006; Wed, 22 May 2019 17:59:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E59706B0007; Wed, 22 May 2019 17:59:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF8F46B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:59:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d36so1537660pla.18
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:59:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Fr/1D7LjScAdJIpCIdEEs+cPcC/pVsJ/UPsPaj+zwiU=;
        b=jwO++l/92uxdT4MRrjcna033bnuLy7EkcI4nPOs987LCpUQSIvGYnHQOMmv2W1GHlf
         E8hmkQcBUbb/Vk4C6oaJ9hlcnyNvoo7yiRSO9MOxeF+MrUWVrBfigHWjGk3wHqf6RmML
         os/LCBgk25ZZ+4PWtwtuUrXExEZBRCybSI0tctkAM810fbzUPXdyK5TOP1PfXpfHDOqh
         GHwvxSzVJ40OKJRJGaIp18nZZ3yaY28vQ3AEXhPZTbDSUCtcnVgBukCEHAl+Ii4uljji
         SFnwFq3EvrqYgurzYMEUC6PLf0yM5YxgRL/VVSB83FWnKQFnoVbrTfbnr1R2WsjN/Xaw
         USVw==
X-Gm-Message-State: APjAAAXHFpnP5OdUMGlOPjQ2csGfg6rFtpYVK5nmzuJYpuzsrSNSyqcG
	N+bfILYFosZfJ8ahm8q7BKv/2fcEByGig0vZdXg9sOW1ig7+CNz1BffV7xSPeZNFTM7WM8n+kcG
	Lpg3sh62WiW60JM2a1ZzBoYFPFMtjWdp6KVhQANhiMDDeqZWpfos7Z7nsfhiGYRGR5Q==
X-Received: by 2002:a63:d615:: with SMTP id q21mr91021744pgg.401.1558562349405;
        Wed, 22 May 2019 14:59:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUes6ItNH4TiNh3wBwmtAY+4m7ODplUoNEt6816YH2nWzShEnykYcuhF/etOA84nkRXuOm
X-Received: by 2002:a63:d615:: with SMTP id q21mr91021721pgg.401.1558562348757;
        Wed, 22 May 2019 14:59:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558562348; cv=none;
        d=google.com; s=arc-20160816;
        b=S+bnKs09HbX6g69U1e1z5a8UrjRUyLDbQ5bbtNSe5yQGp3vjpTIdgcmXm7AMmzWJJJ
         PBaBsA6f456/O6fVtrz2sj3xdJhEtqyg5xoLjBthkwEi6bIYyGP4UAQCBkU57E/NfaLy
         3MR8uBrIBLoB3TO595JGDdj3x5u0dktpLZKM/2vVKsW4msmpJnHtS/mqwbHkEJJD+Jz5
         enbux02Dg3UdwRmLJJXKYv6NLFCZ7pRB/DCHZ2eG2Hw2GT0Q0B0afsDhj5wh/ZZ7+tBp
         5BFB46croV50LIo7vMX65s/zqfT0Jojvr6oa3BxmdvhLpxlOSEyxks8CvH3gMhHZ3VdH
         PyMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Fr/1D7LjScAdJIpCIdEEs+cPcC/pVsJ/UPsPaj+zwiU=;
        b=pNce6ARnURqfdhMVKDZZbyqB/oVXH7i8PcLm7sQKAc+UgC2dp/yYE5U5+jr2QnVF+5
         YhdAUbJZshuFCnDAuclJET1JstKLlkXW7uzERahBtOiFQbkICx9Bzon8mNCN3X6HkCAs
         /KH06A2DfU6n3y8r/Grqr9UqweWswecRRzQBi55lkOQre9nzeNwIu9Nc/oanhGZNhyJz
         kKc7c7qnb2fCTM87WkXnSSDZV3GqespjOqFRKaUeU+Q1XaQzxAuNJLLefIM/T1ZieayN
         dWLSJCAWYb8jucehu9M3h0mpZnDD87hsIA5LUk6ZxV1ms708wFut49dqcmPFVwsb4e/E
         RZ4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Zr8gMdgg;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s13si19811291pgp.95.2019.05.22.14.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 14:59:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Zr8gMdgg;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C966921880;
	Wed, 22 May 2019 21:59:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558562348;
	bh=R6YcL8U8yochP+E8Zmsq6kuoz61IzyX5bMmtEWQzZLM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Zr8gMdggwmhhfTmcy+QmNgZLg2PfZ0TLrnp3IRFmnindd1nPaBjrlLwXUHhcFcytS
	 S3fMlA75Nma6WNodFnANzU6+BozwhoGgdbcFd35fq7GZgrJZGvmrImtVwo3Ov4aZDg
	 yyUMoyBBA3v49PwKKRYZio8kePJ/lBN6j6NRI9zQ=
Date: Wed, 22 May 2019 14:59:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team
 <Kernel-team@fb.com>, "Johannes Weiner" <hannes@cmpxchg.org>, Michal Hocko
 <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, Shakeel Butt
 <shakeelb@google.com>, Christoph Lameter <cl@linux.com>, Vladimir Davydov
 <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org"
 <cgroups@vger.kernel.org>, Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 0/7] mm: reparent slab memory on cgroup removal
Message-Id: <20190522145906.60c9e70ac0ed7ee3918a124c@linux-foundation.org>
In-Reply-To: <20190522214347.GA10082@tower.DHCP.thefacebook.com>
References: <20190521200735.2603003-1-guro@fb.com>
	<20190522214347.GA10082@tower.DHCP.thefacebook.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 21:43:54 +0000 Roman Gushchin <guro@fb.com> wrote:

> Is this patchset good to go? Or do you have any remaining concerns?
> 
> It has been carefully reviewed by Shakeel; and also Christoph and Waiman
> gave some attention to it.
> 
> Since commit 172b06c32b94 ("mm: slowly shrink slabs with a relatively")
> has been reverted, the memcg "leak" problem is open again, and I've heard
> from several independent people and companies that it's a real problem
> for them. So it will be nice to close it asap.
> 
> I suspect that the fix is too heavy for stable, unfortunately.
> 
> Please, let me know if you have any issues that preventing you
> from pulling it into the tree.

I looked, and put it on ice for a while, hoping to hear from
mhocko/hannes.  Did they look at the earlier versions?

