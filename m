Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B56C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 20:31:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 216FF20823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 20:31:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JFeTGKR4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 216FF20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A658A8E0003; Mon,  4 Mar 2019 15:31:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EC718E0001; Mon,  4 Mar 2019 15:31:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4E88E0003; Mon,  4 Mar 2019 15:31:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0F08E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 15:31:35 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 207so5364274qkf.9
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 12:31:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=z9mIcxxt8Vhpd9V+/EyizlMRIl0unlkK0sf4EYC970w=;
        b=n4pi43xvrFcz5oBmIFlpPhahxunaA2r3f2EQVAVifCSVZsweviFYmXF8q40ZU/5pS/
         x1u7EVpvpvvmJ15M585JDC79qqGPnFYDopGnuvnid+/6AtrbtQdLSKHQpDIoGoOQAXVC
         pvSUy77+ghQiu5hKChNT41uU21s6I47pC9CMJ+3wmTM0bcnAfnXSyUkGAEtxsp0j65tr
         6BhnhNLzVfyWYVOHr9y/bhCxNNYIiMv3zv//cUUsaOYnHk03iV9RGnCX0DTtuGiXCmhw
         Scc4oGnouKOXOxJZn8jHQrc+/zh+7H+DdGFMBxGy2bz01QOjLL6//3kGyvrVleftPauJ
         r3wg==
X-Gm-Message-State: APjAAAUDj9/IcSNT3Uyip/ccAB8XBjk6cxgTPw7ESoDVIUgm+vjDV/xn
	i/EKFtZt0F7wgl8sa+o2cdxcPM0VWMfXQBX9ZmmumC0j/AS4mh3i/vzlgjzTviXTMUgdSIp9KpF
	4knquuxa/FATjD2WjKDFRqvbGpE51aPmk2j0NiKBPdrOjvvHFYyXbaQUuAvphbPiXLp6apiKnt9
	qye2OX2qEOamwwyDPwrJ1XD6Z6/L9hjIL5niMvUnx+8ydswvNqZIl7l65H6jeWNOJmAzOFt1Erx
	XxLIklc5yCMX3f/K+d9Q8KnnWfrr5jqCDn717TIfwdXSQhnXRJe08sj2PPCSKPKFbNOKnmLymk5
	K58Wne6MthgtSCAAobFLq7KFLjeEdU42JsHJofgi9eWFk+ULIwzoDEWZd13UxHKjt4MghJImdGe
	u
X-Received: by 2002:a37:a783:: with SMTP id q125mr14579075qke.264.1551731495030;
        Mon, 04 Mar 2019 12:31:35 -0800 (PST)
X-Received: by 2002:a37:a783:: with SMTP id q125mr14579038qke.264.1551731494184;
        Mon, 04 Mar 2019 12:31:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551731494; cv=none;
        d=google.com; s=arc-20160816;
        b=rCyADJJeM4UTtsI8CZQ8Ca6pKDE4JQ4Bsf6UAVWoTiLP068pMT1l+u3Rmvth3eOc6J
         GQD469Bqzq+CyvjQ8HP8D/Wv8uKXodMwwzaVM1kB2L1zaYuLj/hphs+BQm4Ndv2pRi1r
         zIjm1eEfZW5XEFMeMyUv12ZlP+D2JdCie1K75fLzX4XjeBguMof/AAEhruDYNXGudXUh
         bJza0RDCmO9qUxai6C09n8Si3bk6ijZrcZ2w3vyU6TSNZg/H2DEB1t5fwSGB8J1UqBn7
         4PAWDO5czSkM5gKnC/lMyFpOBx3IqyVOIpkh0X2z24nsM36KnnyH64BSMmVJSUx/aTOg
         9x9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=z9mIcxxt8Vhpd9V+/EyizlMRIl0unlkK0sf4EYC970w=;
        b=AbMnceT8VreK23Av9quILnv8mfK2Z8ua1vx8GEpouHTN2cmehoRHBeOC9j00FQ/RBR
         kVE8gQnNUONju9RVvY1ExKFid/IHamTBYvtC6eVJ7y3H54ypKqDjZKUI2EGhi0GV0IPX
         IsTn1wTMOujg1/tnEgAOHny8Gp7ISc/BhaIulss9gIsherxMHK48SDIazZfgnTfvHqvl
         oGdTtP1S3Cj+SQBY1qvkfF3BB4iPKfc87JBUMiYXR0T+VhePTXiY72yXv3A18h0/FrEj
         buqtx0PZqGZ58PlZqsyJn/1xSHWbqDNNkDHYo8iotzTXPA+e04/hsNV4z09kdwq3dQIq
         R1jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JFeTGKR4;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a81sor3807075qkg.130.2019.03.04.12.31.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 12:31:34 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JFeTGKR4;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z9mIcxxt8Vhpd9V+/EyizlMRIl0unlkK0sf4EYC970w=;
        b=JFeTGKR46hqecjdgXUCXA+PrbOcfhOUKyqsz887pdoaKWDSgn6hDTL0Vw2FtXeY27z
         uqHxm+aSfSxHxZ04/5/ZtHeiRLJEW7inwMIPplCUR4hpul8lUHW40ct3ly1elJgUOtl3
         2f7QDs6t+X10nndWu2iI0sbpfI2fUOIuDRKNJlnEQK9p17hrAo/g/LtwaD8rWGOATZG9
         /Z+HAQhJD3m9L4bWuMRZNEIloPHbC/1kenvBf/HdjZ5ZRgkljDYALHNnXkZn20kyTsfd
         u/JCaroIdy8grFikzQJOZwoS9sX/C/R/aTXdqEFhaZl9tooNa1cnx7fhZisHUuw/d1Zy
         cd3g==
X-Google-Smtp-Source: APXvYqyctoESLU+Xtxd++N/+Ff3gZfUlHc/dMEjqqr/V+Al9QV4wBeo2newWfQLW5Xw86infcw5cnQ==
X-Received: by 2002:ae9:ec19:: with SMTP id h25mr15120648qkg.122.1551731493848;
        Mon, 04 Mar 2019 12:31:33 -0800 (PST)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id f58sm4696098qtc.14.2019.03.04.12.31.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Mar 2019 12:31:33 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h0uFI-0000Hb-73; Mon, 04 Mar 2019 16:31:32 -0400
Date: Mon, 4 Mar 2019 16:31:32 -0400
From: Jason Gunthorpe <jgg@ziepe.ca>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Leon Romanovsky <leon@kernel.org>, Ira Weiny <ira.weiny@intel.com>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Message-ID: <20190304203132.GA1055@ziepe.ca>
References: <20190304194645.10422-1-jhubbard@nvidia.com>
 <20190304194645.10422-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190304194645.10422-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 11:46:45AM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> 1. Bug fix: fix an off by one error in the code that
> cleans up if it fails to dma-map a page, after having
> done a get_user_pages_remote() on a range of pages.
> 
> 2. Refinement: for that same cleanup code, release_pages()
> is better than put_page() in a loop.
> 
> Cc: Leon Romanovsky <leon@kernel.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Acked-by: Leon Romanovsky <leonro@mellanox.com>
> ---
>  drivers/infiniband/core/umem_odp.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)

Applied to for-next, thanks

Jason

