Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E44A3C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:16:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C41C22CE3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:16:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lecystT5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C41C22CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 375216B0309; Wed, 21 Aug 2019 12:16:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 325C96B030A; Wed, 21 Aug 2019 12:16:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ED366B030B; Wed, 21 Aug 2019 12:16:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0014.hostedemail.com [216.40.44.14])
	by kanga.kvack.org (Postfix) with ESMTP id ECCBD6B0309
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:16:37 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 97B428248ABD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:16:37 +0000 (UTC)
X-FDA: 75846938034.01.earth80_1cad7df7d9f39
X-HE-Tag: earth80_1cad7df7d9f39
X-Filterd-Recvd-Size: 4976
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:16:36 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id x4so3707911qts.5
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 09:16:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rSelPuss6Rio+zLxmeT3lHQjONOPz6ghCteSl79uvc4=;
        b=lecystT5pa2A6yo8Axdj1KSsLU40VESQnnpU2Rk1L1SzDdZmYUbd4PsiNU+5iLOE7j
         zbD6bbLCGebQwx9lcXa2B+HW9DoD5q7uBa/gZ7ygQPx77wQQIQ1GmTexMMrPCdK7kyCX
         dcyjDO+jw/ZpT3eBIlbTDS/F9lvZmJkfsIhEr9N+LJxXNscIOIrGwF+RrgQg/pAcfw/v
         C6mD6PK7XpC9IuEvG2lpMuOD0oHl5qpDhT5vYuAjCVMq7SKO6jJn1/Yli0UUb+PtB3VS
         3uspvkistGavDwQta/lD1VQQk7IwUnquCu4OISrFvHvchWTZq1eeFmMkErGSgo9qyGp1
         hN0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=rSelPuss6Rio+zLxmeT3lHQjONOPz6ghCteSl79uvc4=;
        b=WWTNIH8auNfuJDRDUXNAA1Q9mt9hEf1JxaUpcGMdhT1GdFVJJxmijYXcTKg2C3mlzL
         68Kz6gCtPGSG+INWmc2HQ4/3mBMKdpDjMQ8+FEtlg5bMUjthtgFGqZMRp539KmcNzw2d
         rbCCxx5UwLi383F5YNnS8ZBvgOHBQkg8iYr8mLgzU6x2MvjNwliRH0cHfSpHHbtjWbTY
         B4hia7rDiTRCwS5yiTZLb6m3xCW2et1spDRzSG4O43loi073z2JRdXFO9VTjzjTpogzP
         KDVMdDj4p68DvWE4u7UphTanitThh7PGiB1Ov3PI6kapn1L3TbX9Chq7wFnmabjIeeUg
         NtwQ==
X-Gm-Message-State: APjAAAVBXbHXkEhJjyw7UxyTXboMReRFmWAdLF/hCxbqJnbIejI3Qnh4
	zbY7ACfDcodSHVg2Q6/geiFVnQ==
X-Google-Smtp-Source: APXvYqypokR94+w8NKN6DkdxQ9oFTavnyiG1VlybQkUXWne93Jd3wfqkFsQtWY3s57Jl+U7ZTrZ3aQ==
X-Received: by 2002:ac8:7696:: with SMTP id g22mr31568522qtr.208.1566404196241;
        Wed, 21 Aug 2019 09:16:36 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y194sm10143420qkb.111.2019.08.21.09.16.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Aug 2019 09:16:35 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i0THn-0008UM-3g; Wed, 21 Aug 2019 13:16:35 -0300
Date: Wed, 21 Aug 2019 13:16:35 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190821161635.GC8653@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch>
 <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local>
 <20190821154151.GK11147@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821154151.GK11147@phenom.ffwll.local>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 05:41:51PM +0200, Daniel Vetter wrote:

> > Hm, I thought the page table locks we're holding there already prevent any
> > sleeping, so would be redundant? But reading through code I think that's
> > not guaranteed, so yeah makes sense to add it for invalidate_range_end
> > too. I'll respin once I have the ack/nack from scheduler people.
> 
> So I started to look into this, and I'm a bit confused. There's no
> _nonblock version of this, so does this means blocking is never allowed,
> or always allowed?

RDMA has a mutex:

ib_umem_notifier_invalidate_range_end
  rbt_ib_umem_for_each_in_range
   invalidate_range_start_trampoline
    ib_umem_notifier_end_account
      mutex_lock(&umem_odp->umem_mutex);

I'm working to delete this path though!

nonblocking or not follows the start, the same flag gets placed into
the mmu_notifier_range struct passed to end.

> From a quick look through implementations I've only seen spinlocks, and
> one up_read. So I guess I should wrape this callback in some unconditional
> non_block_start/end, but I'm not sure.

For now, we should keep it the same as start, conditionally blocking.

Hopefully before LPC I can send a RFC series that eliminates most
invalidate_range_end users in favor of common locking..

Jason

