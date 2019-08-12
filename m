Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04F07C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:00:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD03620679
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:00:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LV/5e5bv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD03620679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AE626B0003; Mon, 12 Aug 2019 09:00:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55E5C6B0005; Mon, 12 Aug 2019 09:00:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4749D6B0006; Mon, 12 Aug 2019 09:00:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id 26AAB6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:00:42 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D34682C34
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:00:41 +0000 (UTC)
X-FDA: 75813785082.28.son93_7a7282a3ccd1c
X-HE-Tag: son93_7a7282a3ccd1c
X-Filterd-Recvd-Size: 4725
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:00:41 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id u34so3345748qte.2
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 06:00:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=v27wNdJ2y4fYwnlNFEt6zNAiJxMsGAli8ivaPg3wc1M=;
        b=LV/5e5bv9v8c9I7DK/4tP8vVkAv6ndU5JI38qUo1+2B1jfGlrpI06NbB/wUkGmGyeD
         KY3vx+BUEfWjNcT2jjwpyELSCXp7i7rhZc2KX9VIhPMNn4kdIu0t67lAdfyU9nekK3/L
         3MP+wXH4WlzFyTZrxx9Nd58XuCITcoHJXYChWbVPAs14UWUvJfZCxKp6aHXHdcIEep4x
         r+prD4FcMDTQq1FtSuu4IHqp4tIQ7RstC8NDn1Eia7VGs9b5kzm5e4WhAMu4VOynEmb3
         TrkDaFXVCw6fu3HohAu2/SmzPW7CoZVyBc26hhltk64h6IL73zahCzWzhawOMhGp4fqS
         1wtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=v27wNdJ2y4fYwnlNFEt6zNAiJxMsGAli8ivaPg3wc1M=;
        b=T4FRuDvK+UoptgcZL/vNAPuOTizdasTwyOXSbp2z9Wbqo2/3aBQMplCsh6RpwZGYUI
         0i8S7/3B+10tC/md1Mk6bBgEQOGvLpk9uIjgBh0TRJ8b0NXTN/Zoui8zGVHfj/p/FH63
         qW3SIS0xtvgnIZ9LVi6M57Rgd+T+ZoqU2N5fKG7UHGyqoTfyBr5j7kBFO3422pagJwBc
         9c17DkgO3sk7oDYRgsqxdWJxTSv91nzBoBrH3XRc6LwdkcaPM2pOzn0dBHog14PnItz+
         azkoeJFiXll996cN98kEjC7oD9zvEaXnuRlD5+cA1bQxeNOBmIe+ky3Rioo1wCd1O/yp
         066g==
X-Gm-Message-State: APjAAAUDZ7ecz5HwuATaZBot+1E3d55/fVVT1BkcMkWYcmf1+SJtkRYo
	wvcmnkFFNbTZiFSoVPfise6vsg==
X-Google-Smtp-Source: APXvYqyQID2HK/cSNFy0j5AldC0D5f58clAE4+2HeEw+kkaB2zL8GXSnMyU9v7OrdqZd4L0OHplsYg==
X-Received: by 2002:ac8:6c48:: with SMTP id z8mr18986870qtu.58.1565614840799;
        Mon, 12 Aug 2019 06:00:40 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m27sm52693265qtu.31.2019.08.12.06.00.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Aug 2019 06:00:40 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hx9wG-0007QV-0U; Mon, 12 Aug 2019 10:00:40 -0300
Date: Mon, 12 Aug 2019 10:00:40 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 16/19] RDMA/uverbs: Add back pointer to system
 file object
Message-ID: <20190812130039.GD24457@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-17-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809225833.6657-17-ira.weiny@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 03:58:30PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> In order for MRs to be tracked against the open verbs context the ufile
> needs to have a pointer to hand to the GUP code.
> 
> No references need to be taken as this should be valid for the lifetime
> of the context.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
>  drivers/infiniband/core/uverbs.h      | 1 +
>  drivers/infiniband/core/uverbs_main.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/drivers/infiniband/core/uverbs.h b/drivers/infiniband/core/uverbs.h
> index 1e5aeb39f774..e802ba8c67d6 100644
> +++ b/drivers/infiniband/core/uverbs.h
> @@ -163,6 +163,7 @@ struct ib_uverbs_file {
>  	struct page *disassociate_page;
>  
>  	struct xarray		idr;
> +	struct file             *sys_file; /* backpointer to system file object */
>  };

The 'struct file' has a lifetime strictly shorter than the
ib_uverbs_file, which is kref'd on its own lifetime. Having a back
pointer like this is confouding as it will be invalid for some of the
lifetime of the struct.

Jason

