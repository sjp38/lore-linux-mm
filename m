Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 824A9C10F06
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:36:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26A312184E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PXodbKoz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26A312184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BA676B0007; Thu, 28 Mar 2019 22:36:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76A786B0008; Thu, 28 Mar 2019 22:36:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6325C6B000C; Thu, 28 Mar 2019 22:36:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2575B6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:36:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n63so448980pfb.14
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:36:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x5wrJojQMwMMqNV4mUTxSiikQGMgZPFASdd4DPbfGYk=;
        b=lvLMbC2JZOHOnIddJ/ugU0YDJs6ktIAHKnm5xrVE+EzBWxpR5o5U/8D2OqIh3HcU4Q
         4BrH3Kr5g2l9SXcrd45pGGHGBP8piuMbxD+17eBjbk3Erofhx0pTHl60Life01JBuC+a
         Pa9hmbZANuuvk2ox7EEvDHpjSvlpgPSi4iNBaTLaogbx9L9NrGv94niX/JvPEgW9jpYV
         6+DLxQJKqnYx/aTcSA0Dd+k7qtdFefpxeleyAR9z0FcekGrIPiuooBP/GiIF1SIouzi2
         xUBHQ88FcIYEFCcv2UplEE5taJnXELgPDTbTtxD1ya0tU3u1NJgh4++hNtKreQ7LBo3L
         Ay0Q==
X-Gm-Message-State: APjAAAUv7dFvmb4taMbwaM/5j2SvKrfWfxKscloCjIvoUDjMhE+GOePg
	hFO4Lj5Qm2QuKmFYjXeFUI9o1spNPDjgoea1Yr6Lj01kiE8tj1NQY9vUtu9mGP7Mi9R3k8DspLt
	oNJkRDskKxleI6H8NJVhvC8CwDfQkv3r/8u+CjhVaoY6kiwYYvTqIj/aRQ7n/7FSVvg==
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr44381056plt.275.1553826965757;
        Thu, 28 Mar 2019 19:36:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqRJXIXoaDgVRZQMFFNTeBWUVFN35bovaaBdUFDJ6nkB8/QUq/bloNbkwgGhwhRl7V7dly
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr44380984plt.275.1553826964649;
        Thu, 28 Mar 2019 19:36:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553826964; cv=none;
        d=google.com; s=arc-20160816;
        b=mJpsNOXecLkF+Yn/Ua3Y9YDGhqLQ7ZUTtjSP0iEZGOKieh/mUWDXx+mgmt4FqIcNR+
         qatDcCryCX/apGHiQZ69ScLAQd+N+9mWrRySDTe1gbl34pSI7T1XwscIQ+8ONzi55bCs
         f+t3FokHcgYcRgRIOjVpZvnuxd4M508p71sAlaxUHGo5secASDNggUMTYWTbHr714Kwp
         6TsH0t8u2jga84tDuaovQxAw9PDgQOXZ+Ozm+5K3bBsuudUqMqPthBJYQijLwhPG59cY
         uwoEp4A/2PRLUrAqYA1WJTdblBHtvR/L56TGlBdCZz3K+Zi5E2qlHdTyiHvojkbEaPT7
         fK+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x5wrJojQMwMMqNV4mUTxSiikQGMgZPFASdd4DPbfGYk=;
        b=K7BKWyfDXJRydicMPwBvvLg8mh5rLZqZ+bL5ss5LjWcBYs30PCjQDlH9WYq0qSx6u0
         xpMjzXtR9c8DGJrFKIpkhbmlqttsfpXlpZYeMwd0Gia11aj71iSF8Z3nEyARblwn1I5k
         T8zruDzIEOL05BfVsuS5LQwWkrBYqHgvdcDy3Nxf/50B1FHggbTiJezssvXNF1eEnHvC
         fg48wWQY51YskUL1M9LXQIo/KVT82hdeoXUV3e6CVSx2rurZp0r+bpZ9K4cBMvMIUHXj
         hZnhdSIEhxaWG6aJitPyv6k26nLHYusA42orGsoe2zZrvqUOi33npULByHL+EpZ3ERII
         cAfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PXodbKoz;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j5si681690pfi.166.2019.03.28.19.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 19:36:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PXodbKoz;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=x5wrJojQMwMMqNV4mUTxSiikQGMgZPFASdd4DPbfGYk=; b=PXodbKozTbre1PKAnjXqjKbQv
	xHZWToZbgAeVVsGULg9dl9/vJlMuQy1v4CVR/DM3ujbpNrs0G8UrSkbbR5vCaXOEhikUrxz4preRj
	8SoYWLQTUvdfUquKH0N+DG9f0pkEb6zEmhQ1HPPwc6Dt0Y6n6Q0XzfL6lrV3wK8t8Ow4aOzPBkvyU
	SUzMfyObSEtBJGnh3SGZ0IQM2vOuYIDipmD0A9wb9/Y5tVrQGx5Br3Nkm/0MwSg5lxY7yBJ554lVe
	n9kg7bodgAEErghL+I/5CEgcAOjn+0KAKLKSv463Ui0evX4GqNxOdxpcgG32YWFMBnET2wUWTXVSI
	QCYlBdpMA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9hN3-0000Eh-Ii; Fri, 29 Mar 2019 02:35:53 +0000
Date: Thu, 28 Mar 2019 19:35:53 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Ben Gardon <bgardon@google.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	linux-mm@kvack.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm, kvm: account kvm_vcpu_mmap to kmemcg
Message-ID: <20190329023552.GV10344@bombadil.infradead.org>
References: <20190329012836.47013-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329012836.47013-1-shakeelb@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 06:28:36PM -0700, Shakeel Butt wrote:
> A VCPU of a VM can allocate upto three pages which can be mmap'ed by the
> user space application. At the moment this memory is not charged. On a
> large machine running large number of VMs (or small number of VMs having
> large number of VCPUs), this unaccounted memory can be very significant.
> So, this memory should be charged to a kmemcg. However that is not
> possible as these pages are mmapped to the userspace and PageKmemcg()
> was designed with the assumption that such pages will never be mmapped
> to the userspace.
> 
> One way to solve this problem is by introducing an additional memcg
> charging API similar to mem_cgroup_[un]charge_skmem(). However skmem
> charging API usage is contained and shared and no new users are
> expected but the pages which can be mmapped and should be charged to
> kmemcg can and will increase. So, requiring the usage for such API will
> increase the maintenance burden. The simplest solution is to remove the
> assumption of no mmapping PageKmemcg() pages to user space.

The usual response under these circumstances is "No, you can't have a
page flag bit".

I don't understand why we need a PageKmemcg anyway.  We already
have an entire pointer in struct page; can we not just check whether
page->mem_cgroup is NULL or not?

