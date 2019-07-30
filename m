Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82B97C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CB24206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:10:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CB24206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D2B8E0006; Tue, 30 Jul 2019 09:10:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDDA88E0001; Tue, 30 Jul 2019 09:10:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCE5B8E0006; Tue, 30 Jul 2019 09:10:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A98468E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:10:41 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b1so31849564wru.4
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:10:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6clvNznROtvjhzOJWwCkko7QVSqipOkuyqK0JiGyYdw=;
        b=myYNXtL36iFmW4UXWaJe28mTBDe4e/rs5kaIaYMvCEDUOQHhecvYc66+TjSoLaEUg/
         pnaaO7IX2UjBCPz/xEiWMn+cwEcLik7mVCGU8+no360I+L7N5jdKnZ7oiQAsIh00cjxx
         dKCB2pIzxvCKjwzqSRmKx5MEF+fsmgrU2T9TNE2yrKFsJc8WsmkOc6dTV+9b6X/PR2VT
         gP4tYA5oaGJuNA1vgIyOU9vtK2yJQE+fEfYJ6PdUqAsMyxExpYBc7BNh7H9uXIBufBUT
         fjy2CYZOCWh7Ad64p9AWVhIExGj6+7qIvH4geJSZI7jrD3eX0BEwSZRmQk73NW0aA2pt
         oVMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVm/225YKLLPU6B/bU3ESvI/KXJ237yeTAaom4VaeyrHzpslkQn
	5UINuc7JPZhYVrMeTlIrLG7n8/ne9VLahUME7r6A3gCe3eQP8GlJTs9nlStU17ZCXPrKt2n1buo
	HGiU+ROsCicVHJ4GgPZeOj0NQb8GhP7htdHrUsbqj2cgZHmCGWwTjYw5Qli+QH6XKkQ==
X-Received: by 2002:adf:f84f:: with SMTP id d15mr126154038wrq.53.1564492241299;
        Tue, 30 Jul 2019 06:10:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzg85VPB/YeHMArjL5jVXRTGQFCzcuungsrBL0jFTWE1GWd1M9PNUzwOfeyln+HvdRMAf0
X-Received: by 2002:adf:f84f:: with SMTP id d15mr126153953wrq.53.1564492240609;
        Tue, 30 Jul 2019 06:10:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564492240; cv=none;
        d=google.com; s=arc-20160816;
        b=GpPckvbyx14JJDI0Fs8eXtRQMeo1Vxp4FYr0H399LUzY+zYEefzGHdkba0Uvp9WxbB
         ZgmFT2K4LnkW518ML1iFCidmDg8XFKyfPss91H+DF3hHCrFqnl82R6tvbhIGGLVLsApx
         uA9UZ8fwnYm05QYnwkNVprYr+qHRrBhMkZpUTAG3jWBqt9nQzI2VOpMczFozgqQD2s8+
         cvuC2yFf2gb3A+YiB232T/KJH/cM497G5pKIFxknEX3dJ8PvBL5Yg+IzSkTMYqerqO+N
         Tni4bEtFMVrxpCZt2HF2UXYnxC9XUg4JpXLQbEQB4SKsKbl6Mi9SAPk4boCBx7mkE9nx
         R4Pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6clvNznROtvjhzOJWwCkko7QVSqipOkuyqK0JiGyYdw=;
        b=gfBmGFCyGPFaFOSYD111X1Fh5LvrKRRyBbjH5lcf+p06kGq8Zbm40Bvlm9YJsDAh3h
         FyMRuBmztbkmmO3QYmFKWzZnV6Qm0/vbiyrN8JuXIkQZ2vOgSxZJoWZHmCPZnckP7DL/
         lw4i13v6eq0XWHLNuGT+/6qYTu+nf2FJlUXVyA3Mq7AtFrrR/oDnSqK7j532/Zu9fUo0
         RCyEIWb6PwVq9ggTvvtreHNkuAo1XunKCLQ6qEplRApHxguSvKGe+5I+wxVIiil+WY2/
         HOvQCGI+igX7MQLYplU2VEKOdulIzE+WVzXWal92lI+AWR2+3ePqNfAUK0S9IIvVhrYY
         ZbOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s14si61704733wru.144.2019.07.30.06.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 06:10:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 98FD768AFE; Tue, 30 Jul 2019 15:10:38 +0200 (CEST)
Date: Tue, 30 Jul 2019 15:10:38 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/13] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Message-ID: <20190730131038.GB4566@lst.de>
References: <20190730055203.28467-1-hch@lst.de> <20190730055203.28467-4-hch@lst.de> <20190730123554.GD24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730123554.GD24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 12:35:59PM +0000, Jason Gunthorpe wrote:
> On Tue, Jul 30, 2019 at 08:51:53AM +0300, Christoph Hellwig wrote:
> > This avoid having to abuse the vma field in struct hmm_range to unlock
> > the mmap_sem.
> 
> I think the change inside hmm_range_fault got lost on rebase, it is
> now using:
> 
>                 up_read(&range->hmm->mm->mmap_sem);
> 
> But, yes, lets change it to use svmm->mm and try to keep struct hmm
> opaque to drivers

It got lost somewhat intentionally as I didn't want the churn, but I
forgot to update the changelog.  But if you are fine with changing it
over I can bring it back.

