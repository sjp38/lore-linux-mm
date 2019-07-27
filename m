Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7564C7618B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 10:13:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C029C20840
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 10:13:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C029C20840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26B0C8E0003; Sat, 27 Jul 2019 06:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 240498E0002; Sat, 27 Jul 2019 06:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 131F48E0003; Sat, 27 Jul 2019 06:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D12498E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 06:13:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so35473881eda.9
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 03:13:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JbEDAElGhBvQS+cUD/l7SvM0bOJzGScQl5oJeAtgUQI=;
        b=AMYq8R+GTQKEswx/ef+8oq7LUXVHPboEgvGtYN5uevAyl8GfDXHW7GY8IhGah6Wciz
         pYQHAyzuW8ASRHMp4FB8gHV+dxxXn0wGOCu0HKYIva4LEzchhwcN++Al4QR2D6sa/KFI
         Ugw08eH3Jmiiw3jWRmMwp8xT7/TCFgMWW5Fi9FHs8tNsHN46hGi1Yq9deSdStCfpYWf1
         /9e+j/t9AS3/unpkwkPUQyw4DZSvFnwVvHaBfItmDNG8uIVNwLOBPCiltAq0IxH5W14I
         0Y9bU5MUkQ9BpuNtAjN1qMoeeeFFezKn9I8qCAPaA1+AcM0noulX3WVJqFtNoFdXElvi
         cVHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWsuJf+qz51thF8rJVhu0qzcs6b0FpWZSQfbSsfATckH6FqifOL
	e7hPxSkLInQkIKRn9JWnmrZBtFiTdAADLf88ri34z6sj3L+7c7NjDPJlJVsPOz4FuurK/kxn6rz
	ZcL/BJV9MH3ltCrBnKOEt3wu6coYA0LeiKd1iK/OBJUzwbDmZ8ZDvyyaor718jNzwZw==
X-Received: by 2002:a50:9f4e:: with SMTP id b72mr86746594edf.252.1564222438402;
        Sat, 27 Jul 2019 03:13:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3/uisYHCC58khY/KW/TvOtESL1EwxXtNoMwEpByTLgM2Y3sAPwwDsEouM3XGJnSXOSpYI
X-Received: by 2002:a50:9f4e:: with SMTP id b72mr86746557edf.252.1564222437668;
        Sat, 27 Jul 2019 03:13:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564222437; cv=none;
        d=google.com; s=arc-20160816;
        b=NX4sCpsEG24DM86eZFmqwI2xXJUQ2dgk5XIprsUEflE1M+gM6jMoIP5MXCi6BHcmwi
         jwr4vqHMLP/NxwQR+dBS9yctGZALBsYGf1NMasq7lytkfAiunfZb9Z67TOb7e8WjGAZn
         RTPnsLKIN1A47s0yZzFXuYqkfy/I9I5w4jhQNLnbaoCKq3Lqov4t+9wtp2Gvs3JL8t3k
         QQWyKkrKc0mGT8FlrRNadq6Uwus/28Y/2gZYOEer+Mq6fnIdtAZx5JXLdWJygcqCzDRs
         rZur4YvlSeSakDgcXnj3CokPEo40hojOU4HLwXnvgT0PUspmNKXJ5plfjCo5MA2erwZG
         mAWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JbEDAElGhBvQS+cUD/l7SvM0bOJzGScQl5oJeAtgUQI=;
        b=MP5Fex+TbB5GIwP6QnkG+hRTmiBsQHVEYYFndLxbHeExLdcqAm/nWNVcJR2sb5vFKe
         Z3u2wueRrGJNf2ez0R0RqnFT/XUuSFa/1ihL6+eSa6Ac2QKwi2Yp84N0DAbEuCClkGB6
         z82VH2lX8OnxGdwxU6/5a7h5V4vIh7JfQ3wEZTEN3RCtEbjxk4zGsyjlY7A5a/lud0dw
         YF7k3MAOuNq1GAQFwfUEiWnfGLf/2fGGFHU9+x/APkw+xL14T0o6ZqIwyXU0cejNRjTo
         IE960RKx3qCITcA0ApRmnRCfIBBARLSRgMXgTdSX8ukpwNGjgZGl8h46lBHvG1wXRcWf
         /vzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id ox16si12240433ejb.171.2019.07.27.03.13.57
        for <linux-mm@kvack.org>;
        Sat, 27 Jul 2019 03:13:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CCDD528;
	Sat, 27 Jul 2019 03:13:56 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 76FE83F71A;
	Sat, 27 Jul 2019 03:13:55 -0700 (PDT)
Date: Sat, 27 Jul 2019 11:13:53 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@suse.com,
	dvyukov@google.com, rientjes@google.com, willy@infradead.org,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
Message-ID: <20190727101352.GA14316@arrakis.emea.arm.com>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563301410.4610.8.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563301410.4610.8.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 02:23:30PM -0400, Qian Cai wrote:
> As mentioned in anther thread, the situation for kmemleak under memory pressure
> has already been unhealthy. I don't feel comfortable to make it even worse by
> reverting this commit alone. This could potentially make kmemleak kill itself
> easier and miss some more real memory leak later.
> 
> To make it really a short-term solution before the reverting, I think someone
> needs to follow up with the mempool solution with tunable pool size mentioned
> in,
> 
> https://lore.kernel.org/linux-mm/20190328145917.GC10283@arrakis.emea.arm.com/

Before my little bit of spare time disappears, let's add the tunable to
the mempool size so that I can repost the patch. Are you ok with a
kernel cmdline parameter or you'd rather change it at runtime? The
latter implies a minor extension to mempool to allow it to refill on
demand. I'd personally go for the former.

-- 
Catalin

