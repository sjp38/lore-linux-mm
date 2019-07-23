Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E99A2C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:30:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB6CC20840
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:30:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB6CC20840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AC518E0003; Tue, 23 Jul 2019 12:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 582928E0002; Tue, 23 Jul 2019 12:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 471118E0003; Tue, 23 Jul 2019 12:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 121AF8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:30:51 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id r9so10044893wme.8
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:30:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BuplSnnL3WMx/Jb7sI7R9wCtdKIxvBlt+7K+m5n19w8=;
        b=aTNYMUBHUeRJKyEgC5Nf/03in8UXM/ZcdpYMSWOGfF/ZBoF7WSTdWVBM2MOhNHZZDF
         4GeQhDD1dd4ij9z6DmyFOyQ/XiHPtjbsSQnWHn0Us+byPMzqXjhUVaRLojrtQa3G48+Q
         HkLZnVtfjHPRZgSQXxem0z3VqkqujTKVat5fyFBiXmZNncXF7L06keCrcRShi4zlW/v6
         8tlO1YaIQBa40qeRz3cYtCIQ/4TgHG75NSbQG9Y5pu+YrUMcPgt7U0YJXfGOVm/J6gsK
         tuOv6Rdz7s3xf9rbTMsf3UguuGjEZNe/budqhPl1DOPQe9HDD4RgDN/JXLWgNhXCRmBx
         zsNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXgHjoUvt+yOjGwbVYJKtYT+4yxrcQrnyCZDXWT63pye+NDURPi
	aajmO9qVB3iRRWqPudefioq8VEH7RsYihl7aeKD7agMFYkqXFGlaUZMGprEj8Zk2Hqp6L6zKN3G
	AL7WxZVhYQ2O/0zd1uyvpfrf10CQhng9xdnNWLAYKOl0CN6LaQEiZjHo59Go6v6HszQ==
X-Received: by 2002:adf:80e1:: with SMTP id 88mr80064474wrl.127.1563899450634;
        Tue, 23 Jul 2019 09:30:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMC8VSoTf1xiw7jhyvdWjhS5V6xf5kxfLaoeGFQnbb5E9uSt3oiE7pXlqkQQjxZgU7SemZ
X-Received: by 2002:adf:80e1:: with SMTP id 88mr80064442wrl.127.1563899449975;
        Tue, 23 Jul 2019 09:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563899449; cv=none;
        d=google.com; s=arc-20160816;
        b=xltN+KumeEmQeDCVaQLW+zfcNufi7L4f1hfWPAtkGeMGKVVpFTHjQJlfmzbx7G08qS
         /gsKDrfy0QowvE6gDZprdkZnXThWrPQEond5zcJe1fSx2FYGVVk19sai/a1wOMdpx24C
         wCv8mdWM+JqtXIsRXknlHvACNfBh4c3cGp5buhZ4wBeI2lDadDy7XdErSPI23d1vli1y
         qNE8hDBMPFwHKrhEPbIF6hGe788cmV2/V68J5qn998qL5twyP/WJs26yq8IWH8fKU2ot
         A+mctaTrG5KRZBEUck5d8sFqFic3CP1Pwdrjxp7Y6wKsvKUm//HGqsu/U9rFeSmD/Rxi
         E+QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BuplSnnL3WMx/Jb7sI7R9wCtdKIxvBlt+7K+m5n19w8=;
        b=R4AFut7838m76gMVHDleYRfmZR3I+ciDWsluRVbcwg/F7862W68WBodaBznPR37BAr
         nae68mSYTC7ucJoPjJdC0Y/rFeg30wRAzwDWdnpKXz9pMWcOxUZAVwUnJOQPYdR8fP2S
         ySXx0bDcijv82i/eQIjAzxTnJuND+agCAwSHZTHtmkxd2z9vcVGxWIGxXE9zIM7s2Dj7
         eT6BnzdADInPQN3uCV+VnJM2gUjLsi2QlURjR5VmjH5avzoifvWS6rthdnMxkihNZEmS
         ZIPhM/ebVVS0fQpzjJmOxtc/fX/XdUOk+NcvvD/eb/U9+aL9tH0XJDSLgM/QdXODPtEJ
         Ml5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i15si42306528wrx.61.2019.07.23.09.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 09:30:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9C53F68B02; Tue, 23 Jul 2019 18:30:48 +0200 (CEST)
Date: Tue, 23 Jul 2019 18:30:48 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 4/6] nouveau: unlock mmap_sem on all errors from
 nouveau_range_fault
Message-ID: <20190723163048.GD1655@lst.de>
References: <20190722094426.18563-1-hch@lst.de> <20190722094426.18563-5-hch@lst.de> <20190723151824.GL15331@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723151824.GL15331@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 03:18:28PM +0000, Jason Gunthorpe wrote:
> Hum..
> 
> The caller does this:
> 
> again:
> 		ret = nouveau_range_fault(&svmm->mirror, &range);
> 		if (ret == 0) {
> 			mutex_lock(&svmm->mutex);
> 			if (!nouveau_range_done(&range)) {
> 				mutex_unlock(&svmm->mutex);
> 				goto again;
> 
> And we can't call nouveau_range_fault() -> hmm_range_fault() without
> holding the mmap_sem, so we can't allow nouveau_range_fault to unlock
> it.

Goto again can only happen if nouveau_range_fault was successful,
in which case we did not drop mmap_sem.

Also:

>  	ret = hmm_range_fault(range, true);
>  	if (ret <= 0) {
>  		if (ret == 0)
>  			ret = -EBUSY;
> -		up_read(&range->vma->vm_mm->mmap_sem);
>  		hmm_range_unregister(range);

This would hold mmap_sem over hmm_range_unregister, which can lead
to deadlock if we call exit_mmap and then acquire mmap_sem again.

