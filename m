Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7AFBC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89E2920989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:56:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="NMbkgebY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89E2920989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B3D18E0004; Tue, 29 Jan 2019 11:56:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38AA08E0002; Tue, 29 Jan 2019 11:56:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 279B68E0004; Tue, 29 Jan 2019 11:56:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE58D8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:56:22 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a18so14246591pga.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:56:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vql8U89T/hHjjSzQxptcPZRte1dCUtGT4jirdck/APc=;
        b=tA49YCAhVVxuHGCPmS6TfGFaH+sSD7Ysb2QRDQHkrUsUQzFMIp7dvLhzwtGEYzYUPz
         9wNpySUv9au88+frOD4pTMIc5T+Gg/jRJj0/yB+b3IdOVJeuqKwK7m0a1hIGhuGf+mpx
         SanVl3PlUlROWttcR64dZgq+j0CBDaPmtlPdF40rJU1NG6tvO4aF5ow7EtG++40X2reR
         xTU4gODklO0zwRDUBJeOqiTSIkU7cYkTcpaYA2J2cZ/3UCfUklWsaLUfGLM9vYx/euXO
         J7z+AlWbqxaStee4Y85oLagKQo0Fl9kSy6cf8pzwdwi9FLcbETqSYwKKeX9WCOp14/Rq
         ktIg==
X-Gm-Message-State: AJcUukeSe+SKlbnwTxdJcWuIy0/48Ct1CD9iNy8M05JCBbNUyO6s9v/3
	FS8Y6D05djPktldp/vMqqbULsNDumrGlstOTxe5GofG/nef5h80ojM7lo8+69nYt45s5UervVdc
	qBIxcAb42USF/VFVmHvWosV919a4TQnkregd8PhOiuKFboTUfEv6mDrB3DHN/NMrKZmquY6K3Hp
	FapGve6UBlVKY5UXiqo1NOwWDfLCh3F4rMZNrO84QjQGJS3EcQUCccUYRE3OghINl2ra9zXOQSb
	/IAdSdVT8pHn+Ia6lmbe/jd1yC33EgJCMB81mxgUF0pUjsVyUDxww8x8Bf2GM2LgAbiaqTEX8KH
	Yx0KsP7FMgo1KMBaWTvf0FruN7olp6fWiIeuYCCYVLZoV2CUBECBCcXi8HuJK2DIBT2CkHFYJkR
	0
X-Received: by 2002:a63:4926:: with SMTP id w38mr23308059pga.353.1548780982581;
        Tue, 29 Jan 2019 08:56:22 -0800 (PST)
X-Received: by 2002:a63:4926:: with SMTP id w38mr23308034pga.353.1548780981808;
        Tue, 29 Jan 2019 08:56:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780981; cv=none;
        d=google.com; s=arc-20160816;
        b=QTQehLETFOXCxpKeoQJX9boRbF/2kgRovkeNnuX1rTPxRr61qhnWRniKEnCjDFUn29
         0P8gI4F4M6uxa0z92JON1zZEGU4s74H8EDPJ6VuxjzxF0PnQYymisEnKJ0MGJWJJLTDs
         NqLG0A9OC06XZW8RiSl8i83Ndhb9O2JiVgrrhQ7vqZAOHwcfM2ZOn42VbsIv38BBMwB7
         oQ1MJLJ9RhvuTohkS4Z53Gpui22WBvWk+MePgv4LB7lXsf8veK0lsan5Dtff5dq8yHRD
         OiGx+zQJ4A98T93ZksJG4CwdApGUiBJJc2GwGFZDW6MwGPAPPmmDItxRjr9Z/hfX0agZ
         dMFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vql8U89T/hHjjSzQxptcPZRte1dCUtGT4jirdck/APc=;
        b=qtFHLndwJcGCIotAckCrFOjWY7P2HaidnzJnbFn/Ow5QEezM4aX8UKqddCNo+2P6o0
         vgY9Q1UzAZ2CmLmvm5UUzIHLFNWiIfxgAhwS4S1ueMXCO61VeEYJqoLyyJ4gDvQprIiV
         nu2oF5MJWuCFdJpBFNKfIgC8U3DdDDhF6G/HCLlF8kWOlfNcYXJWDb5Og/okT4/jX8V6
         kFPIjbZ3ZLMte3Sr5UW3vAQTD+fRkPlLolRAPf3v8e3J5HfJM0LJ1cp8FlcnM1Lp1cOD
         o06TMWGKq5CNSqJdI+L/04c5HOhyupxLA/U0WgMa2jW+QeY9uSt7zARS9rhBrMMlcFzk
         vVWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=NMbkgebY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a72sor55369622pge.21.2019.01.29.08.56.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 08:56:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=NMbkgebY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vql8U89T/hHjjSzQxptcPZRte1dCUtGT4jirdck/APc=;
        b=NMbkgebY4EHpMOLHRgtVlKvOjuX6dyFymsNZhkYtjK443i2AjiQt+z6bxBHHct8Bww
         wzsMnAoS90uq9JaU2oJNE5Dj2Fv5HyJwccSs2JZtgphXK2yxoG0yPBFToljtFTmEtS1J
         3H6QOdODDPg0gppQzDjVY8zf2ZEMysqVYB9fTESNjD+HSo5sBm9hv1NFY4phiHAh/bFS
         Z896B5MgcgR5WxlxIKu7EXEH8JUxhIRJzQyA+vv6sX3qTwfyyVyofRGenZynTxV/m5Zu
         z7eEt7kT/xq2jWrr4bHJhiZTYNyNozTc2rRc4kRHcEOT9sUrDDzrxgf7FcZMSBGxgwZQ
         PGIQ==
X-Google-Smtp-Source: ALg8bN7ptJmZpJU3paI7ZW9MPDibRYYoJVCL3anlb16ShHdSnpfegJMezROCztjWwoW943HbFr5O6g==
X-Received: by 2002:a63:e915:: with SMTP id i21mr23854042pgh.409.1548780981421;
        Tue, 29 Jan 2019 08:56:21 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id v9sm47049062pfe.49.2019.01.29.08.56.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 08:56:20 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1goWgO-0003Dw-05; Tue, 29 Jan 2019 09:56:20 -0700
Date: Tue, 29 Jan 2019 09:56:19 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Joel Nider <joeln@il.ibm.com>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] RDMA/uverbs: add owner parameter to ib_umem_get
Message-ID: <20190129165619.GC10094@ziepe.ca>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <1548768386-28289-4-git-send-email-joeln@il.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548768386-28289-4-git-send-email-joeln@il.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 03:26:24PM +0200, Joel Nider wrote:
> ib_umem_get is a core function used by drivers that support RDMA.
> The 'owner' parameter signifies the process that owns the memory.
> Until now, it was assumed that the owning process was the current
> process. This adds the flexibility to specify a process other than
> the current process. All drivers that call this function are also
> updated, but the default behaviour is to keep backwards
> compatibility by assuming the current process is the owner when
> the 'owner' parameter is NULL.
> 
> Signed-off-by: Joel Nider <joeln@il.ibm.com>
>  drivers/infiniband/core/umem.c                | 26 ++++++++++++++++++++------
>  drivers/infiniband/hw/bnxt_re/ib_verbs.c      | 10 +++++-----
>  drivers/infiniband/hw/cxgb3/iwch_provider.c   |  3 ++-
>  drivers/infiniband/hw/cxgb4/mem.c             |  3 ++-
>  drivers/infiniband/hw/hns/hns_roce_cq.c       |  2 +-
>  drivers/infiniband/hw/hns/hns_roce_db.c       |  2 +-
>  drivers/infiniband/hw/hns/hns_roce_mr.c       |  4 ++--
>  drivers/infiniband/hw/hns/hns_roce_qp.c       |  2 +-
>  drivers/infiniband/hw/hns/hns_roce_srq.c      |  2 +-
>  drivers/infiniband/hw/i40iw/i40iw_verbs.c     |  2 +-
>  drivers/infiniband/hw/mlx4/cq.c               |  2 +-
>  drivers/infiniband/hw/mlx4/doorbell.c         |  2 +-
>  drivers/infiniband/hw/mlx4/mr.c               |  2 +-
>  drivers/infiniband/hw/mlx4/qp.c               |  2 +-
>  drivers/infiniband/hw/mlx4/srq.c              |  2 +-
>  drivers/infiniband/hw/mlx5/cq.c               |  4 ++--
>  drivers/infiniband/hw/mlx5/devx.c             |  2 +-
>  drivers/infiniband/hw/mlx5/doorbell.c         |  2 +-
>  drivers/infiniband/hw/mlx5/mr.c               | 15 ++++++++-------
>  drivers/infiniband/hw/mlx5/odp.c              |  5 +++--
>  drivers/infiniband/hw/mlx5/qp.c               |  4 ++--
>  drivers/infiniband/hw/mlx5/srq.c              |  2 +-
>  drivers/infiniband/hw/mthca/mthca_provider.c  |  2 +-
>  drivers/infiniband/hw/nes/nes_verbs.c         |  3 ++-
>  drivers/infiniband/hw/ocrdma/ocrdma_verbs.c   |  3 ++-
>  drivers/infiniband/hw/qedr/verbs.c            |  8 +++++---
>  drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c  |  2 +-
>  drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c  |  2 +-
>  drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c  |  5 +++--
>  drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c |  2 +-
>  drivers/infiniband/sw/rdmavt/mr.c             |  2 +-
>  drivers/infiniband/sw/rxe/rxe_mr.c            |  3 ++-
>  include/rdma/ib_umem.h                        |  3 ++-
>  33 files changed, 80 insertions(+), 55 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index c6144df..9646cee 100644
> +++ b/drivers/infiniband/core/umem.c
> @@ -71,15 +71,21 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>   *
>   * If access flags indicate ODP memory, avoid pinning. Instead, stores
>   * the mm for future page fault handling in conjunction with MMU notifiers.
> + * If the process doing the pinning is the same as the process that owns
> + * the memory being pinned, 'owner' should be NULL. Otherwise, 'owner' should
> + * be the process ID of the owning process. The process ID must be in the
> + * same PID namespace as the calling userspace context.
>   *
> - * @context: userspace context to pin memory for
> + * @context: userspace context that is pinning the memory
>   * @addr: userspace virtual address to start at
>   * @size: length of region to pin
>   * @access: IB_ACCESS_xxx flags for memory being pinned
>   * @dmasync: flush in-flight DMA when the memory region is written
> + * @owner: the ID of the process that owns the memory being pinned
>   */
>  struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
> -			    size_t size, int access, int dmasync)
> +			    size_t size, int access, int dmasync,
> +			    struct pid *owner)

You need to rebase this patch on rdma's for-next tree, the signature is
different.

Jason

