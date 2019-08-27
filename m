Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A26EC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 22:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFAF82186A
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 22:48:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="aSF2iwwB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFAF82186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69C126B0008; Tue, 27 Aug 2019 18:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64A326B000A; Tue, 27 Aug 2019 18:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 538956B000C; Tue, 27 Aug 2019 18:48:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0001.hostedemail.com [216.40.44.1])
	by kanga.kvack.org (Postfix) with ESMTP id 317E46B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:48:07 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BD87B87F8
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:48:06 +0000 (UTC)
X-FDA: 75869697372.17.dress96_c92e5f3b9106
X-HE-Tag: dress96_c92e5f3b9106
X-Filterd-Recvd-Size: 4077
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:48:06 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id k13so764214qtm.12
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:48:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jAdr+PRt2FqgbS5XOOCJ9tvwJq0Sqr672g8uyJKHQxE=;
        b=aSF2iwwBLFQuLQ3N3kNXqi4CQ/GTjnkvkPNw4aniyErIM3MO0qE94JDqgop+jXAoq3
         jHHWiV4hBrwmm2iTgCoiRlhwqpzuD3mb9GMj1eDsOI+G8Gw4AuMgNGE4i/bvRk5AXep4
         3QR+vmYkm6GNw7pLeIbfet89BHMr+yn7nrfaAqOOgrIEOmAm9QShaaPeo4Zh7ka1jkS0
         flHWhhQqdnPpw9YrY1Gz1VVlC/3jJZCLzkDGaOrcdJt3Ym2wbgyWdfXAsDkVJEeCfsxi
         HzmxAs0pTu4mFFQrGjFlWSK845EFVbxXJ63cZlv39gtlVKZj9nxayW/KPLVEPcmjfZNr
         cT/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=jAdr+PRt2FqgbS5XOOCJ9tvwJq0Sqr672g8uyJKHQxE=;
        b=G6okkp22EWYOEXoOxqpLAx23w1kkiRsJ74gPVbMGBDBjOK6vH67BfOI30Sz2zTssZT
         jqEhClOdzzkCMkPuqtd3jpAwXDy7ftVjpdugrAeUFB6aPBDnY99F5LqAk0QbY4id+Iia
         IePPmQQIDqMxzvXHSBupj3CN5p0Ctm1Ie2W8etBRB6xMu3rHKQx0niJ7yeC6QAX5Awy2
         UMxiVqy5i+mhPj0MfPtbcKM2v0DQCcp1fTDomdTe4AykPRPDe9PNfhBupa4l7BMhUcBA
         52KGP8WO8uHRaMiiwGWhz14/1sUd5mjIaCbLOGbi9bweGvOTM8enZgTe3zyAc6XenkAd
         5CJg==
X-Gm-Message-State: APjAAAXKA1xtuSicQkxHfy8nXvsExFSt7Bkl7SoEsk62ZJbxyP5FaVX4
	RmXTz0rddvxrZX2+GIotfbX2Lw==
X-Google-Smtp-Source: APXvYqyjKFWmKMA8MMlDR3xLrO67hCPYAWB96imqMAMJ3ql8fO8EwALYjIVqzuf6Fw3X4axT++r5lQ==
X-Received: by 2002:a0c:da11:: with SMTP id x17mr841622qvj.197.1566946085712;
        Tue, 27 Aug 2019 15:48:05 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-142-167-216-168.dhcp-dynamic.fibreop.ns.bellaliant.net. [142.167.216.168])
        by smtp.gmail.com with ESMTPSA id y5sm462004qkj.64.2019.08.27.15.48.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Aug 2019 15:48:05 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i2kFw-0003mf-RO; Tue, 27 Aug 2019 19:48:04 -0300
Date: Tue, 27 Aug 2019 19:48:04 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 0/2] mm/hmm: two bug fixes for hmm_range_fault()
Message-ID: <20190827224804.GA31299@ziepe.ca>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823221753.2514-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 03:17:51PM -0700, Ralph Campbell wrote:
> I have been working on converting Jerome's hmm_dummy driver and self
> tests into a stand-alone set of tests to be included in
> tools/testing/selftests/vm and came across these two bug fixes in the
> process. The tests aren't quite ready to be posted as a patch.
> I'm posting the fixes now since I thought they shouldn't wait.
> They should probably have a fixes line but with all the HMM changes,
> I wasn't sure exactly which commit to use.
> 
> These are based on top of Jason's latest hmm branch.
> 
> Ralph Campbell (2):
>   mm/hmm: hmm_range_fault() NULL pointer bug
>   mm/hmm: hmm_range_fault() infinite loop

Applied to hmm.git

Thanks,
Jason

