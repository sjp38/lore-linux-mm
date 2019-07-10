Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 890FAC74A23
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 13:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4507C208E4
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 13:47:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="VrcajUFH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4507C208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8A438E0076; Wed, 10 Jul 2019 09:47:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3BD28E0032; Wed, 10 Jul 2019 09:47:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C01418E0076; Wed, 10 Jul 2019 09:47:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F29B8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 09:47:37 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f28so2252728qtg.2
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 06:47:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7U6Nt7OEfvKxcNWy+tvVorAtvgeJ3jhS1Gu2nX61T9o=;
        b=ja+uy9p2PQ0BwZYlCnq5TAmMIPeZZzvd4esT3rWqSqnpT/aHboKWfHq6rwRRfonydN
         JcdZVGdBOBOOmU/AMVeqqknHY39F6GHOFPBKw7FFh1wUUkfN42TvQL6YS977Vut/wqWK
         A5JcGcss4H7hMHaNTjlkSJbXoXBe3ZJlr86DiAu6UUmEOar8X8Pma6KZEmBFqkgkvZ7X
         4aDFgjNXXLoNXMN5a0i2l1aJJq8ZwEA/5Zh/qmz/TIyvoPcActXR40BIemg4EicXK7X1
         WtPM2v0lFhlVnx4twzsGD+/5yx9pVRErptBpc/Peq9H1heHt1L+ZXeDHNouZhOfwdcSd
         /VGA==
X-Gm-Message-State: APjAAAWAh+Z+F1XZidMvlSBS21dgoKQpwAzIOA2i6nq2ssdkh8YMtkh7
	fmMwuD9tJZrHejRglVOFoRWg5mgMv52SVygnWjwLYsNTwSiKhVxizNhEQZsFTda/m4ag9M2H3vC
	4/54vVfBbnNliryfj/1bnzmlvREScxLvLVk/4jY4MQ41s/SQKkrQBjqbBSEekSnediQ==
X-Received: by 2002:a37:be85:: with SMTP id o127mr23794992qkf.194.1562766457359;
        Wed, 10 Jul 2019 06:47:37 -0700 (PDT)
X-Received: by 2002:a37:be85:: with SMTP id o127mr23794950qkf.194.1562766456599;
        Wed, 10 Jul 2019 06:47:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562766456; cv=none;
        d=google.com; s=arc-20160816;
        b=xxWOYv6tp66L5RbETJi5U+EEl0Cr/XmS+zmc2MsQZyT9ubY8NaR1bgl493L7BwqWug
         74jZxFVewaHY7qK60bmvrZbjkkZGnBHkL6zWXXVdEKnxUblTnG2U2dCm4sDZpZHY52Yi
         ncExJg9eKUZjlykrZAHIo34nV8GFVdpkSxKozOflYC790AxXdZDo4lVSUqVKJ/MFzNud
         uxx1vofxe8Z+e9j8k6nBbQgWqoMOdYzb92eytsUuwwf1r1+DKaqfNnffD2MowOTVEhFF
         3tyKRNmoUpiGGsvQaitaChgRDNBOzX1lgcy+/UlPPtoBDgvdC+mT4i33ln6pa11X7ViU
         tw2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7U6Nt7OEfvKxcNWy+tvVorAtvgeJ3jhS1Gu2nX61T9o=;
        b=KXc5U9Qui+IA7hYr7+g7omk1sD/mlHC0oy/+p+NHHP8JLounNsppv2LVOyL+TYaeXy
         jbh6l2BdnhiigPBXxLmzV0tCllEnCm+Pyuf49UjVT4kZ948j9lo/7s8+nBjZB+8MNKPq
         yIFKmKq51755ji+v3vkfeirJPqn5jHlrToYr1OW1JZis7w+0iPdv5+H7q8W+Jj939m45
         HxXxmlLVZa5tyYaIn4dDv1i0/ac7c5vbYBL1d4Ydm1UyAphtivkF+AonfAmDVvb5cn9e
         ys3NjQiuw8vEp94AH5YkI+cpapZeQNid+F7FxcoGjHtHtcW8vjjLAljXQyjRWrIE5eSJ
         CgIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=VrcajUFH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k30sor2156114qvk.58.2019.07.10.06.47.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 06:47:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=VrcajUFH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7U6Nt7OEfvKxcNWy+tvVorAtvgeJ3jhS1Gu2nX61T9o=;
        b=VrcajUFHnL11D6RL+P9on2xGE4JRl04eDGqwQa5qHE8yXtYmOepQdn7ImaobBudj7h
         BbrC4OOPHj5Qvw25DS/glET43DNZGXzIRQGBpRQUKbEsXspnhXlZ3KGsM7Pp4aC7bYcy
         xDwg42eG7T/GACYBefhfJvB8Acg/r/4AciCDj9FzSGNWN+gTJPVnDtkmPiLQt7KFx4lc
         xLv01uYuGtD+S7G0ERpM+v/8K6p9F4eb7g1kmAVVHkUxI/XZN8xEVEnCzMR1FKB74vmG
         gZV7WpiK/hm4dD2vXlBdZlSLCSy2C12W+pykqbzTB6uX0Io3B56dcV3GvUGjIDbdWAxJ
         3QcA==
X-Google-Smtp-Source: APXvYqygCMHzTUHQC/+aI1gVFaxUXYVDQQtJfFKzO9aN4lth9Iok18xe2Gb/ZZLBzuS0ZLO+5Jk8kQ==
X-Received: by 2002:a0c:8b49:: with SMTP id d9mr24649143qvc.178.1562766456016;
        Wed, 10 Jul 2019 06:47:36 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o18sm1314520qtb.53.2019.07.10.06.47.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Jul 2019 06:47:35 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hlCwY-00013E-UQ; Wed, 10 Jul 2019 10:47:34 -0300
Date: Wed, 10 Jul 2019 10:47:34 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: janani <janani@linux.ibm.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org,
	linuxram@us.ibm.com, cclaudio@linux.ibm.com,
	kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
	aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
	sukadev@linux.vnet.ibm.com,
	Linuxppc-dev <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 1/7] kvmppc: HMM backend driver to manage pages of
 secure guest
Message-ID: <20190710134734.GB2873@ziepe.ca>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-2-bharata@linux.ibm.com>
 <29e536f225036d2a93e653c56a961fcb@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29e536f225036d2a93e653c56a961fcb@linux.vnet.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 09, 2019 at 01:55:28PM -0500, janani wrote:

> > +int kvmppc_hmm_init(void)
> > +{
> > +	int ret = 0;
> > +	unsigned long size;
> > +
> > +	size = kvmppc_get_secmem_size();
> > +	if (!size) {
> > +		ret = -ENODEV;
> > +		goto out;
> > +	}
> > +
> > +	kvmppc_hmm.device = hmm_device_new(NULL);
> > +	if (IS_ERR(kvmppc_hmm.device)) {
> > +		ret = PTR_ERR(kvmppc_hmm.device);
> > +		goto out;
> > +	}
> > +
> > +	kvmppc_hmm.devmem = hmm_devmem_add(&kvmppc_hmm_devmem_ops,
> > +					   &kvmppc_hmm.device->device, size);
> > +	if (IS_ERR(kvmppc_hmm.devmem)) {
> > +		ret = PTR_ERR(kvmppc_hmm.devmem);
> > +		goto out_device;
> > +	}

This 'hmm_device' API family was recently deleted from hmm:

commit 07ec38917e68f0114b9c8aeeb1c584b5e73e4dd6
Author: Christoph Hellwig <hch@lst.de>
Date:   Wed Jun 26 14:27:01 2019 +0200

    mm: remove the struct hmm_device infrastructure
    
    This code is a trivial wrapper around device model helpers, which
    should have been integrated into the driver device model usage from
    the start.  Assuming it actually had users, which it never had since
    the code was added more than 1 1/2 years ago.

This patch should use the driver core directly instead.

Regards,
Jason

