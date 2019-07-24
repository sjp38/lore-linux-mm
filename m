Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89ACFC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36EEE22BED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:25:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cizJvBvS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36EEE22BED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE9FF6B0007; Wed, 24 Jul 2019 15:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9B7A6B0008; Wed, 24 Jul 2019 15:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C62E78E0002; Wed, 24 Jul 2019 15:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A42B26B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:25:06 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id j81so40093242qke.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:25:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OkPU/CLyukMOj3ZbNY/O7tpHR8CxfiQ425Gxa1fb2JQ=;
        b=phaW7KKhWxNDvlHKs4m6QGrrnGNlIFrMq2/jloZyPJE17kDvJxetPeUpsGqusBeUij
         sXz8RZH2aw+HnVBIf9Q3jOe3Tn01/aOYJTOQ1Lnj1ynnnKneXeWR3YwzBbLfUKxqfLvD
         qECtBlMg9jvnXJOlXEN6UK9S+2y2xpdAaaCg7CpNZp4WWFZNv1IEVtM3czohZUsfvo6O
         FXLx8cRWi+/IT0ZZQWzfglDPz6GKXc+OtCHJpLbxsUV16Xv9IOa2ahq4W2wtfNcLuRLY
         4fEUw3b4MP+tccRkh0215fWwPQ/WBzpM/5GVxOFuvvTRUk+02F6VHEBCkEeRXhtZQVbU
         b78g==
X-Gm-Message-State: APjAAAXOPyW9tFOblgNQZbjZjz88bulPpUsFET3430vaLliIiciMD6dK
	+BHjH0gcExxjU6zAIBObWwkFJZZc82BQnlkkoJM/nf+vRpl5WRkzMbWseLS87bf/knjlaP0959z
	FcwcvJgz5u0fgLo4EDrGs03mpYm8WUumBc143bnmOUQv40qKPKH9idyUctIGSY6qtng==
X-Received: by 2002:ac8:70d1:: with SMTP id g17mr59888109qtp.124.1563996306437;
        Wed, 24 Jul 2019 12:25:06 -0700 (PDT)
X-Received: by 2002:ac8:70d1:: with SMTP id g17mr59888096qtp.124.1563996305938;
        Wed, 24 Jul 2019 12:25:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996305; cv=none;
        d=google.com; s=arc-20160816;
        b=q4qsNmtKBNI5NlnOonMI+9zPjuquh69YbF/hOfuVPfpnYPB3sSNd3sSKskciISralA
         YU/h1VNynGNZASXC+fiFCFY/dbNLvxyQDHx17AC5y1cxZXhDbkpQ0T8VchKHWr0cjk73
         bBYQGAhZXMImJQoFUbpagYTjDDLO/UiH23PZnhARAnQi1KmXtPcE/C8+yohYA++fdhgb
         p+xCvmQX/VPMhaRzaSmWkme7z7lpg1a/6wjvVTvHXgw68Ut8difvY52BmAwleoIdb+HQ
         cZ6T4NBoZqNNBXNgIFSWaxE43OWd7KBQvW2Zdybsmdoaed2OdKamUjOJBdfYwj/X9MPY
         2y1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OkPU/CLyukMOj3ZbNY/O7tpHR8CxfiQ425Gxa1fb2JQ=;
        b=MIJtSAoOkzR14DDHU9nrm6XtW+TQ3OCuIgc7v5batUzo9GVxqCki/x2PHka7jmVjTL
         n2COTotcxdI3g7PRXyEmXNIq5q+M1EuHtJSxWYqgyVMRaCbYP9MaxxzGKOyiOKO56PF3
         ABihmU2WjhTUL4ZNcUfVe2KKKWpTD/1bdkPyRsIUdGokNrBmUVhZ4RpQtls157qWntez
         emQk6Tp8RB+5+BBejO8bG67sIkAu/muZPPOA6zuL4YlzbjrxxfaNYZYap9qCS7ebvsTU
         +5gNFoSYpSsWkRNxVpK/mgxjVAW//tyoMQYIxzFu9cpAuyFgTCL8HNxKQ58WdGWYZn2i
         /WZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cizJvBvS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q130sor27974448qka.3.2019.07.24.12.25.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:25:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cizJvBvS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OkPU/CLyukMOj3ZbNY/O7tpHR8CxfiQ425Gxa1fb2JQ=;
        b=cizJvBvS9LWtQgqD7tHrOnbfUKLn3IKwTexaKlCz0aV8WGl+nqxYE5pseR5xXgl2ZJ
         m8csupMpr7OwAKhyoW9lBHKDfnN0nYwK9z7/RsX4VX3pqa9PWl3XI5/GUR4dWGbBS/2X
         l7xDDDeEor3Zjue37hzwItxKtPGOFgmLJ5n/YPHgvOS+Y7TaohrswgfdoQ2xx5ljLnn5
         gCACdxiqqXuMTz9u7PVtheBQ9dr7K2gpEpuVehHqwNFqED9VeiqZrebhSMSMl/zhVVtH
         139CJQm906dlJU9cmPZyBRd9LIjBH6vCpXIBSECVQGTTiiTBHHUCo4qXoOTM7WaE9BBS
         G4Sg==
X-Google-Smtp-Source: APXvYqyhflls5Pd07xc/KaSNWazAfdY/U63489DoRwgjjWJQqGNW++Rr6B+pQE207tw0i/3votp85A==
X-Received: by 2002:a05:620a:1f4:: with SMTP id x20mr56790548qkn.415.1563996305707;
        Wed, 24 Jul 2019 12:25:05 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r40sm29245885qtk.2.2019.07.24.12.25.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 12:25:05 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqMsq-0001Uo-Fh; Wed, 24 Jul 2019 16:25:04 -0300
Date: Wed, 24 Jul 2019 16:25:04 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v19 11/15] IB/mlx4: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190724192504.GA5716@ziepe.ca>
References: <cover.1563904656.git.andreyknvl@google.com>
 <7969018013a67ddbbf784ac7afeea5a57b1e2bcb.1563904656.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7969018013a67ddbbf784ac7afeea5a57b1e2bcb.1563904656.git.andreyknvl@google.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 07:58:48PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Applied to rdma-for next, please don't sent it via other trees :)

Thanks,
Jason

