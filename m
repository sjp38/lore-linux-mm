Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E601C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 22:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4948D20838
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 22:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="h2wee1T3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4948D20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCB588E00BC; Thu, 21 Feb 2019 17:59:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7A9B8E00B5; Thu, 21 Feb 2019 17:59:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6AD78E00BC; Thu, 21 Feb 2019 17:59:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87D078E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:59:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a5so254493pfn.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:59:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jm4drYWQ+zzE9+IfJHgzMjeQ4vONzj9va9RWmBRBNa8=;
        b=s1I0jxsvqOtGEIy6+jC6MxdSKP7eUtseynbPAFF7g4//CQTDbF/gD4rnU/nAIFWN4V
         qe0sF8RQXiQAXfflWwLPv/mEA2PoxiJKlS+SmVARvHUxdrfzQ26hZc9Gtdb24jAV6qI4
         nFJMKHgWd3hngKaIyMJmIy2+ZABD+VKLFpVrM1Gp5DOsec6IUIPCcRCZsPyk/hhvUBai
         Lr8/JY/SyOa+fKgSuKeSvg4+wGuBT/gP2aAJRYU+sVqtH2STalZc9f0WcNH4Y9TxNGhO
         srxC+JQvYP7AQccp1B9KvZ/VuEesuLDX78kAbCWR/4XTqRRVr9m76A1AQaS74F0kqcq+
         fHGg==
X-Gm-Message-State: AHQUAuZ1sUpb+8Yyuo1dGHcCiNrBtGMy2AjjGUIxO7da/5uQYTpNy1YD
	eYUbPYUXDJ5O4oguYSolJWpqmk2HNaJ+f7iO3zqvoCxqW9gIMAT48uChjkotQGeUjD9fVVJq+be
	y9oLz3H8BkMVdbppzaiuq0b+Su8Dcs75rg+44bkr1N1iGtsxvLvS3Nx7BTkFlmYJ4D/3DIxWH5y
	XISGHDeJv/lOElt/oBcrB4cZhTkGg+cLBqb2SSeuUz8SCjfk3SRbWmUPaFPnSoRfiYJyxOUGK6s
	2bblwHlYsNkowlViDsb/t4tekkGcnKQyKccXqLqYQ7oEmgKeMKb0PlOQiqwxS6kqlAMcuA75Z+e
	jfGHtc6sKd2uheBodTtvajDT1vqIhrjRHCMFbEikhZbA0AxQE5eXwfoJPulOwa7jmbouwD7Ybjl
	U
X-Received: by 2002:a62:b2c3:: with SMTP id z64mr914060pfl.149.1550789980163;
        Thu, 21 Feb 2019 14:59:40 -0800 (PST)
X-Received: by 2002:a62:b2c3:: with SMTP id z64mr914023pfl.149.1550789979450;
        Thu, 21 Feb 2019 14:59:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550789979; cv=none;
        d=google.com; s=arc-20160816;
        b=riUpvjRb/B0FLoeS4fjb14WvL4ds3FkLF3NmFvZHdfuD8tASQCI2yzk0NsfaIhtoza
         qzxv+D1hk38ELHZCetq0dkP00ltgvome1Zz9oCailaYkqlQVcJnufl6bf64w9L4su3xq
         9b3h82otyf7Hi7S4DJCTslRO+xnqZbESYDd3/ONJqfN+grwxPsUiDjSQyUAgtIDsraZL
         SFbcPoLnAzo9wnj/VqUI39waTXeQVdn6JNkrUPGKzoVL0boD+BALH9cq0ezj1A1Clrpa
         Z8OXxPfCDvRbq8mSul1f+F6hFAglE4Og4xtOMxlhJ6Mc2//Wt37666FJO+12yiPdWUas
         Udnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jm4drYWQ+zzE9+IfJHgzMjeQ4vONzj9va9RWmBRBNa8=;
        b=It+10ej0F0LwbzBYTcnMNnCJx7wPPIolNg0oHeMZQkPpEG2TSHqeWyn4b/dIgq2nwP
         f6SG3rRHaBgARqRKD6cBcPU7cCyGJnQTIPS+n3YgqLjDlpkf/dGwu2PDeuAdSnf/QR6t
         qFO4eok0ZYRhmUjsEZDroSVA5DYQ20QJNX5+QNS4H2G0TH/lqQ7Us/DJXXzSOzR5Vqid
         FDr+7r9KBIPQzI3AcCswP4rJ9wQxqmwVDZzrsnUV4HEdQEKfa1K70DbNvQystGklJv5C
         LEP0zwiO6KGx1y0kc+nMaoLtDAmAvLcUDx7coB4Y7j2so+fcZw1MOitCSEYsuItbTVUM
         SmvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=h2wee1T3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f79sor220290pff.7.2019.02.21.14.59.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 14:59:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=h2wee1T3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jm4drYWQ+zzE9+IfJHgzMjeQ4vONzj9va9RWmBRBNa8=;
        b=h2wee1T3eGM7ZVK2rCHeA0MksTAWEdnnUQlZEjY6Nlo1cu/C8sqy7azb72EjNcNoWU
         cEnMESLt3SGZWKBCuZR6z7OL8sHYesnkkTLScD9Q5TFkMoOvbi5cw1Gz6ZN6TNI6y8d3
         yMmTGCgAJbTTJa3XBaq7UT7OXd/e41RzfdLSuRFKgXkeU0DFEIHfGSE6wKscwianDAiJ
         T6ZPxieoyZl5iDocO7tBfLWFffG0i/8jMOlbM9vCDNzXrlQv0qTaCZ6wvnOfiiVOU9Qk
         87OT3PYApUgzK7JXn4HMf8LKmG/MkK2eNriTfmimehoY2mSo1a1ZARJwFq+sWuPzEQdM
         EVDQ==
X-Google-Smtp-Source: AHgI3IaaCNIIKr9l7A5Za3rx8mLVdG6YZR82ClTb05TH/Gm3hk65KOSMHslLnj3J1fKmPLTrg1Xg4g==
X-Received: by 2002:a62:4299:: with SMTP id h25mr897328pfd.165.1550789978923;
        Thu, 21 Feb 2019 14:59:38 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id c7sm126868pfa.24.2019.02.21.14.59.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Feb 2019 14:59:38 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gwxJZ-0002fH-9d; Thu, 21 Feb 2019 15:59:37 -0700
Date: Thu, 21 Feb 2019 15:59:37 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Haggai Eran <haggaie@mellanox.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Aviad Yehezkel <aviadye@mellanox.com>
Subject: Re: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Message-ID: <20190221225937.GS17500@ziepe.ca>
References: <20190129165839.4127-1-jglisse@redhat.com>
 <20190129165839.4127-2-jglisse@redhat.com>
 <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
 <20190212161123.GA4629@redhat.com>
 <20190220222020.GE8415@mellanox.com>
 <20190220222924.GE29398@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220222924.GE29398@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 05:29:24PM -0500, Jerome Glisse wrote:
> > > 
> > > Yes it is safe, the hmm struct has its own refcount and mirror holds a
> > > reference on it, the mm struct itself has a reference on the mm
> > > struct.
> > 
> > The issue here is that that hmm_mirror_unregister() must be a strong
> > fence that guarentees no callback is running or will run after
> > return. mmu_notifier_unregister did not provide that.
> > 
> > I think I saw locking in hmm that was doing this..
> 
> So pattern is:
>     hmm_mirror_register(mirror);
> 
>     // Safe for driver to call within HMM with mirror no matter what
> 
>     hmm_mirror_unregister(mirror)
> 
>     // Driver must no stop calling within HMM, it would be a use after
>     // free scenario

This statement is the opposite direction

I want to know that HMM doesn't allow any driver callbacks to be
running after unregister - because I am going to kfree mirror and
other memory touched by the driver callbacks.

Jason

