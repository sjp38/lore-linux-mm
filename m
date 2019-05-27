Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50A21C46470
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 23:12:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16E6320859
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 23:12:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="CZiPuQaE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16E6320859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A71E96B027F; Mon, 27 May 2019 19:12:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22CD6B0281; Mon, 27 May 2019 19:12:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9A06B0283; Mon, 27 May 2019 19:12:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 669D36B027F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 19:12:43 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id 45so4185540ual.21
        for <linux-mm@kvack.org>; Mon, 27 May 2019 16:12:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wX6N01CkJjaDlOJ1ros8bm2onANhDW8NXyCYvkrtemg=;
        b=JyWoJr/i7krkXGOeEptSjKIJdiC16NdWPKijoXBp360Ck077jb5jUorgZmDgBhtU6+
         ZdGTjyQqjTn/hYkGrbRJfVKTpGufM/7Zm2VI+irQsjMf344CdZq+1MQSXdcYfzfQPQxb
         RD0/YVYGQUFQq839R9Joutk9X0PXB6axtFY5hHn+lyyupvPhZeZaW5Ertb/SzbRPPNmo
         P8UmP8vVEnrk6EW4RBUEFt+CL7nFijXlzEu+vXf6H30cnZno1KkSWcLcMAPw06eb+i7a
         SseLTANModk640ZtuUW/PqOefhvuht35vujbs/PqLzWwOgKLMzoPzhvK+ew+IHaVwXn+
         +sCw==
X-Gm-Message-State: APjAAAXw76VkRJyPqCzIcVt9rsy+IOBq3HJFl3/KFFxtyl+OiOkKVxOM
	rsRvarVTkVBLCfWf6Dp255NUc2jdzL5JzIXxM36iQX/Uf/SWEvnxNx4Q+JgmFzeG/WSQFLzoaVo
	Uxaj3qfy9O9dLIFaavBqAFK3WMc1GQh5eRxjhWY29FadRvyeM7QxJzTyh36B3s61Y4Q==
X-Received: by 2002:a1f:a854:: with SMTP id r81mr22387024vke.55.1558998763087;
        Mon, 27 May 2019 16:12:43 -0700 (PDT)
X-Received: by 2002:a1f:a854:: with SMTP id r81mr22386944vke.55.1558998762211;
        Mon, 27 May 2019 16:12:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558998762; cv=none;
        d=google.com; s=arc-20160816;
        b=GjuvPC/n0oy13x6EP1pDzi8ZM8f3DFn+yI26OV+3/MIk+NWA7W2If/TVfU27Ipcm5H
         h49fYj1U4M3nHhmIx+lKY+MsZTEWaY/8pag0ByIsC/AhUPwNcOD1hvDxI6kOIyert0d8
         GLleyjPO/ydENkt35+rFc6rFFoM07Fn516ebAevs5zqIhsWoH5zkj3TD46qRSXZGY7Es
         H0eccg800F98TBrLoli7rCkqmJHWgUfnS1RcLUC/WBQZ/ivm5Ga+tRK3l9Q7RWt/fQBA
         HTfGkVsamdABFpXoaB/df0hE81KiLjuJkjfZakIsPFyigHdC2o+6i5H+7QGskJcDPzL5
         5X1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=wX6N01CkJjaDlOJ1ros8bm2onANhDW8NXyCYvkrtemg=;
        b=YNFlgI4HZouM6kCl6BEWt0GdDp+9gEoV7WbsPS1WHZvo0AArWs2flz/k9UFwhTwKAX
         oa4hXMXdOQaHLjltWEPqCnVf8cyMgZuboGIRjqPjN+vKGVBGn1f/zIWhHoBnagjsXRbq
         GWDuIWZ8GR87FqfIiZpH5Q/oxTMXhfJyGhG20VHp2RY0hb5ovRwe23AiJ9+S/MIwRT+J
         vAcirZ2RIcVRluTWLoh/ozP5nZdWe/ji3hvMb5gRHf5wBedVfX241g3H3rkh+JLBlzOv
         U54hdOH9aTrszNezAX0juyjGp1Z+C+bAQYowEWLvPQMj5PeAa30z9WdjOhEnE6xPGauV
         DDlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=CZiPuQaE;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor4848351vsn.33.2019.05.27.16.12.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 16:12:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=CZiPuQaE;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=wX6N01CkJjaDlOJ1ros8bm2onANhDW8NXyCYvkrtemg=;
        b=CZiPuQaEwv3lqb5SZe/gadbr2on0uyWsxhzjtp+toaxSYDJsJ0veJ+MsHzoIX193A5
         tGyRL3+z39ibqHrkHL4ig8trKDTVq1uE+qiFVL+hYR3cMJo6o4Aspd5k9Fgs+fP8XTOZ
         EBxJZ1nObd0eaWg5uaSRpy2MVza2dQ+cCF/Qs41qm/fon5bRysCHkLJfqF4gN+OpH5zZ
         HsFELDr80DLkXDrbWdXyBCpSqjsGY+tiobrH4KQ86PlJi0KLZWAX8yW8dgduwngWgKtU
         Mr0WcxTALRjcOItn9ozWYXvUi+Rq2hQhmvWnN4sexsY5xyXZZ4wuDkWK4Q22BTIVNblW
         xkMQ==
X-Google-Smtp-Source: APXvYqy4sB3fYsZi2sRGgGcMy7oWE4xaEc4c4gHWtniQFIlK09l6934M+QPzMYcjxy9CgA/oBmrq0Q==
X-Received: by 2002:a67:fa48:: with SMTP id j8mr50026871vsq.143.1558998761897;
        Mon, 27 May 2019 16:12:41 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a95sm5421589uaa.13.2019.05.27.16.12.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 May 2019 16:12:41 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hVOnI-000638-S7; Mon, 27 May 2019 20:12:40 -0300
Date: Mon, 27 May 2019 20:12:40 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190527231240.GA23224@ziepe.ca>
References: <20190525014522.8042-1-jhubbard@nvidia.com>
 <20190525014522.8042-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190525014522.8042-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 06:45:22PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For infiniband code that retains pages via get_user_pages*(),
> release those pages via the new put_user_page(), or
> put_user_pages*(), instead of put_page()
> 
> This is a tiny part of the second step of fixing the problem described
> in [1]. The steps are:
> 
> 1) Provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem. Again, [1] provides details as to why that is
>    desirable.
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Christian Benvenuti <benve@cisco.com>
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
> Tested-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/infiniband/core/umem.c              |  7 ++++---
>  drivers/infiniband/core/umem_odp.c          | 10 +++++-----
>  drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
>  drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
>  drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
>  drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +++---
>  drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 ++++---
>  7 files changed, 27 insertions(+), 31 deletions(-)

Applied to for-next, thanks

Jason

