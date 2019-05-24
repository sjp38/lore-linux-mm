Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2F92C46460
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:11:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 996F220675
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:11:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VdgAfLUX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 996F220675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42E826B0005; Fri, 24 May 2019 12:11:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B8676B0006; Fri, 24 May 2019 12:11:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20B136B000C; Fri, 24 May 2019 12:11:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D71526B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:11:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id m7so6074431pfh.9
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:11:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XMpCB89ytjbHczxqQZJ1ZkGk4p/wzfOhXhEuznTtcMU=;
        b=HbM05Oe+A9cL9fzCp327P9DCoUPBbr9nuwiVPTV8cAkUxsC+PsTTTwxFjql+j8jiwt
         MkAALWIUA53QBLnkqqzVTXlxSOBa8ECbDnBI+J245H65cJx0YaTWQJhr/JtzuH7LPUZ5
         RDfuART3mb2oh0xzxH+4eLun9O3PmJmKiEEZ0gDhUAUYTgKmnv71s+dQ/IALUPchcEBL
         LBdISx3pftcA70eF8xefP2JZXSbNP5bIARPgKCjjavurtxQYZYfWwpFiYiOn8J+TZwx/
         M7lFTSk+aZyrSeHnMulxci64DH51NVry7/LdTTSlTmrs4prIPfPaBG/o0GpSpFQFdezS
         Cx9g==
X-Gm-Message-State: APjAAAXJOq/nAeRYr4tQbSXf4xvo5nNA7OSHyoYfuRH6Hrq5v69wNy3l
	ZkariqrIPFOj7FEdtkITbPYoU5JI4Fphd5rmBYAh/+2mSvjZLHJVWNlEVKCc7+XZkTu5lWnJoGo
	Yh3VDbkCnqFea76tZUb0KctsxwrKYeoQb9X84rGGLFltEaP1HfjM53vBo5ay9/S6owQ==
X-Received: by 2002:a63:d241:: with SMTP id t1mr15098073pgi.183.1558714310499;
        Fri, 24 May 2019 09:11:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw16TJTFvZRih13NFdmKG6w8NSC3cEK8w19JN17lXzfPB6+DR+WsHohUAw8WFuQBATcUY2p
X-Received: by 2002:a63:d241:: with SMTP id t1mr15098013pgi.183.1558714309775;
        Fri, 24 May 2019 09:11:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558714309; cv=none;
        d=google.com; s=arc-20160816;
        b=BPP+w+kG261FIxDl7mejhC9nOy6Zjk1ONjn4LMnNmlNPDDZB7/G8aYzRDeUlRwE8sB
         Dd6pE5gRufKNOvIoPN8MWcfJuqJ0C1VRMTy7XwPO1hkK7ryaKHVG5DPNj3eyK3Zr6kD/
         cP6mWgGxIIX+NUWxiJXkHvSMFytEBhrH4qAnH4U7VjGcE28DOQtqO+LRtcA+YKYFI9Kg
         ePKfr8YUXX94TnRcZ1CLrrHKYpLKTyjbDvf8OzbHhBRE3JdtJl3bxoeW5L1AQNI1Pp0X
         bI/JYeQY5TiZrZzEhu5RnfJIZLwD8UYKzgyN+oVD4zRgpnXynXfYKgah2f4tIhc6UGwq
         B7Xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XMpCB89ytjbHczxqQZJ1ZkGk4p/wzfOhXhEuznTtcMU=;
        b=mXabV+qxOE0bzOBvV9oDQM3CiE+cVfPm/ShIdnC5LIIOMNaYBccWrTPjs0wdSb2Zrf
         1FKBIJLlIsqGSh3283ymk2K+N2ZDW/A4M4wz+qAs/6826DPx0kDA/UUBJ9GINS2zoJVm
         8T2bplpZqNCP/0KF4rD7X4xQ2U7qphbg0gzPKoQeB/ke61ZwWP4Jo9RBWUdPGr+R+pcR
         8TzkjBqTtN04ZmU4/fsmJmDAgx6/QIOBta8MYYLc3pK1j4Pd1k6JaTa+wvHXJRIpgYbd
         FzCaXo4fOYjqGe2oRGhiBu6pEV5Uy+fEfIESEWz/cLivHTMeYp5MdRNI/KFj8efl7g91
         TSqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VdgAfLUX;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d19si4556052pls.221.2019.05.24.09.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 09:11:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VdgAfLUX;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XMpCB89ytjbHczxqQZJ1ZkGk4p/wzfOhXhEuznTtcMU=; b=VdgAfLUXLCJlXG5l/7G3EXePj
	SSJwDOnYPi2jv9q8sjeH/rp5wl1hTE0k/mlDMPdly9vpf0znyQWHE8P/xVkTzmwchhL3NdHUR7Zut
	n0dGIxrqop8fek0MoEG+PplDVqzElFrd1g2zn+17UZgMLiGSfdYN5pHxWDRasOM76wm59MNcuHm3e
	W+jzXozQbR427BFuT7WuqXHdnjX8+XTo6y+4gsoqt+cCg+b1HDipQVf4KCcyy1Fnn8fUmaDw9HUBS
	80J/IN9BUnKAmEqEy0gKcjABkN60UlsvYuSKfiBxJEEcLE4HITTrK43TTI0zj2SL340n2TrIdrYna
	rs1KInx3w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUCnK-00037T-RC; Fri, 24 May 2019 16:11:46 +0000
Date: Fri, 24 May 2019 09:11:46 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190524161146.GC1075@bombadil.infradead.org>
References: <20190523174349.GA10939@cmpxchg.org>
 <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
 <20190523190032.GA7873@bombadil.infradead.org>
 <20190523192117.GA5723@cmpxchg.org>
 <20190523194130.GA4598@bombadil.infradead.org>
 <20190523195933.GA6404@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523195933.GA6404@cmpxchg.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 03:59:33PM -0400, Johannes Weiner wrote:
> My point is that we cannot have random drivers' internal data
> structures charge to and pin cgroups indefinitely just because they
> happen to do the modprobing or otherwise interact with the driver.
> 
> It makes no sense in terms of performance or cgroup semantics.

But according to Roman, you already have that problem with the page
cache.
https://lore.kernel.org/linux-mm/20190522222254.GA5700@castle/T/

So this argument doesn't make sense to me.

