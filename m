Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAAD5C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 09:10:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86F892146E
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 09:10:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="egAbhAuk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F892146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEB866B0276; Sat,  8 Jun 2019 05:10:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E75826B0278; Sat,  8 Jun 2019 05:10:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D066B0279; Sat,  8 Jun 2019 05:10:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0F16B0276
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 05:10:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b127so3166467pfb.8
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 02:10:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jWAF5+2MrHGGuTvQFl5pQjHX1gq26Kf37occ6yCO+7s=;
        b=KkQHwsufgWMFod8JcN0nA5XMK9I92woLPhB2jL5cdqwLnoXwQDtfZNTje2froDKdC1
         5uNzOCixMFt2VBWgGk35Oq68pr1mQo0472owbydySzcWVxeI5Kg4S9JGwelQoTWUDnoZ
         pxgPXUUpjM36/6bKQbNrfVq9WL93lKrBCuOoMU0VBe8+YjhAYcN0eLMGGIx869e+jHbw
         krx9uu7HCwHErsBOR2h9iBwpAsyM4SY1Vj5uRbAmEs3j+RXmdmqrv0Jj/MEkMn4k33Cd
         IQPpdLaikVcsgZN0ZmgweUlHknUcFi8wFScjnRQ5E8Eaxq8FNvx8pIw21K3X2iX6U3AC
         DmfQ==
X-Gm-Message-State: APjAAAVMrlFOwy6cS0WiiCdsQJODmD7vWsGCwZiItBRVPreIxOeOrYNO
	IuH1EUo3jFDKzHDmGwkZylGyYpK51KAMfqM0abvZK8jUHrYKEt0But8laQM4PHMUmWtjTdfbG/r
	p0o519or7oB/UMceEScSFkBnguFBFdpAatfBq6SWyB5W5OWba0T/fdo2WjBNQti7i9A==
X-Received: by 2002:a17:90a:a10c:: with SMTP id s12mr10233076pjp.49.1559985016273;
        Sat, 08 Jun 2019 02:10:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4r9vhr9da4NUNI517mIINExVxzVuIwHoP12Om0VkXeqhYOWtwFnWiNbZawHU27mMlpC7o
X-Received: by 2002:a17:90a:a10c:: with SMTP id s12mr10233026pjp.49.1559985015549;
        Sat, 08 Jun 2019 02:10:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559985015; cv=none;
        d=google.com; s=arc-20160816;
        b=QwmjPxDDwe2W5+vD8yx31Uvxr0djeYSHhEDN63c8/PDgr+lf7Z96Wq4KXkZkrWd3cz
         V95R9/vkdT5umixYmYelbrxF5SF5Qh9okcp5sZKayKFD0PhCYZ8mHky1dDzh5wWupCSF
         gV7EscY5tZ2aQ8J+91HVEsHyCGLSqr3voiFh3vfIOnKRJvvOxDjh7p3ksb9ajZzzoJ5D
         z+UXnTHaI5zGk/j5g2hOFSQrwCAY0YPGPCrXx3ihRdfNleKDSU1HIrXWJpW/4QeaEMMa
         30ZgWYYa3+i0o8oonqkrbrR9Ut+qKkohh/v1pZuNsERlbIwqunMZoZu2P3hihtPTEtHU
         R4Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jWAF5+2MrHGGuTvQFl5pQjHX1gq26Kf37occ6yCO+7s=;
        b=QWww+Lfn+qBCHcZCA+bYKRlLDk/FoGBgN9ya37otLd6O7Bnm+USdbpTGVBkO3jgEEr
         MpQEBZjfBp5ctz36sX1rJVFMqutmYiMJYvqDTXNasUM3HaxyULStP2FF+qNfZzQL8m3U
         noGUog5IKxMDKWZXRiaevpTj+2GNneJhFrugg+B9vu3LfStg+m9GCSOrenn2HgjtbHyw
         oAu2UPP7bpmSJGzt7Puj0yPhM4wNnQJ1QMSZGLzqpn0vIVbF4Q8p+IckSjWhuA2Nn3N8
         GvE78/GBwTutXSricIXhXemCB7U+p78aJ/oI5ri97t+x+LBw3RtWcgWU9Xiv/fiwyNnY
         OG+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=egAbhAuk;
       spf=pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t18si621057pfh.29.2019.06.08.02.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 08 Jun 2019 02:10:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=egAbhAuk;
       spf=pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jWAF5+2MrHGGuTvQFl5pQjHX1gq26Kf37occ6yCO+7s=; b=egAbhAuk58EO8mWmsVFAI1IGL
	3NGx28Wqh4mlsRk6rZ00vWqQWM9snKOqvzJ8t8oTYp3b7YpQ4FN8ZhKbrlJodVCitb+Vxfv2byRPT
	NBRO5aK1ycIXMfWixI6Hii44xtfrHE8G1KXTx+YJdvNlNvFPERvkjfosNOy0pOMJSRev/soMMoM/5
	AvIuJh9HkQKbxAE+dz94FYEl91SIfv2c4vtlSkMXRjP+nFBN9qBOL2MNvAGJ9SoDWRIVQ+IolhzoT
	n7RKcTtWipcfqFeHOcfjaOXuF634N2hfWMei0HWuZlCxhD+yKfrFhXTL4UzOcxjtOOHD2M63qigYY
	y8qlfJgRQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hZXMW-0001PM-Rs; Sat, 08 Jun 2019 09:10:08 +0000
Date: Sat, 8 Jun 2019 02:10:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, Jason Gunthorpe <jgg@mellanox.com>,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Message-ID: <20190608091008.GC32185@infradead.org>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190608001452.7922-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
> HMM defines its own struct hmm_update which is passed to the
> sync_cpu_device_pagetables() callback function. This is
> sufficient when the only action is to invalidate. However,
> a device may want to know the reason for the invalidation and
> be able to see the new permissions on a range, update device access
> rights or range statistics. Since sync_cpu_device_pagetables()
> can be called from try_to_unmap(), the mmap_sem may not be held
> and find_vma() is not safe to be called.
> Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
> to allow the full invalidation information to be used.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
> 
> I'm sending this out now since we are updating many of the HMM APIs
> and I think it will be useful.

This is the right thing to do.  But the really right thing is to just
kill the hmm_mirror API entirely and move to mmu_notifiers.  At least
for noveau this already is way simpler, although right now it defeats
Jasons patch to avoid allocating the struct hmm in the fault path.
But as said before that can be avoided by just killing struct hmm,
which for many reasons is the right thing to do anyway.

I've got a series here, which is a bit broken (epecially the last
patch can't work as-is), but should explain where I'm trying to head:

http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-mirror-simplification

