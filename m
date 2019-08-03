Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A67BDC433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 15:53:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 689B62085B
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 15:53:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E4xysODT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 689B62085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC4CE6B0271; Sat,  3 Aug 2019 11:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E751B6B0272; Sat,  3 Aug 2019 11:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3E926B0273; Sat,  3 Aug 2019 11:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B55106B0271
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 11:53:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id y19so71163679qtm.0
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 08:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wr1/jf7OC4N1CyD2pZrJRAsqKQhTrW81tkA/dMeoZYU=;
        b=pHEe+6460TXKuFywPWfuZSblKWshlaTXGynNgTS9D3nVA7kEVyne36AaNhJBLHQzrR
         WKHfjF3lNfBx8Fblg2AnZWhhOcWMEdEKIooAIsljcpGl3oNcp9WkmpFc9WJ2I2Kf7sQt
         5KB+EiDY+R66eLvz3lleu5xNbhGeBxT4Z22B8nR7ieVuago+RSATM+PE55su3L2UpQST
         vO676TBncDrQm5ZD95EqoJT9G3se1A5vkgGAZzpbsEFK4H0d2ct66EmhIQYOlM9kSrhi
         IgLOx60rm5ba9U2g/YpSnj7LiWyeFhbT6qhRdtnFbFxJ34MKurg0lr+elsuD2VJyJo+M
         5GBA==
X-Gm-Message-State: APjAAAVaoQ3Vmpr5y5qwLlBEo/JM3CbRan2HD77U+nI04zd3yGvAP4Cz
	w2HMGrO2GcGcfupxQrXtHm+TDS2JZpevSYx6OKRhILv2YTJ3+nPHsGywYAAZtIHMdwOIKbKpNW2
	8kKBTZhcEioOKaklJdR39bVQgmFAQNd6JDd2HOHQ4xN15/r+OvqpNZWOrawAKku0=
X-Received: by 2002:a37:7847:: with SMTP id t68mr92741533qkc.128.1564847632478;
        Sat, 03 Aug 2019 08:53:52 -0700 (PDT)
X-Received: by 2002:a37:7847:: with SMTP id t68mr92741505qkc.128.1564847631867;
        Sat, 03 Aug 2019 08:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564847631; cv=none;
        d=google.com; s=arc-20160816;
        b=MIOorzRCqQCVWQIKLeBEyANZk+eKcNZYLNhZ8BpQ+rlB7+s2NisOWtqLVI01Scn7CA
         DV7T2HtvlHdOAT0O6Vbwej50rt1uspk8LPC9v+VaEh2aDVxdqorTHYwi/HrQMOLNQ5Pa
         uB5j2HMWEtPNIWGx0mxB4flB3CDaYHlPRI8vK79fx9MaPa+mXqXzCZzEVbg1ny84mYpc
         z/ckVPqGf2gEhye4Vh7EF5OJ1ZMwXwdSEypCN0Ds7BltUPzqaeFDi3jdafQrM77qxXp/
         xcU8mg2rKbSjPwSb4IsmxkaGEJzgu0mWqnJXBUKuULpLBcL2QQjcty6tuXYp6/wTtYsd
         BH6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=wr1/jf7OC4N1CyD2pZrJRAsqKQhTrW81tkA/dMeoZYU=;
        b=lyR293073LkvsPuZY7PbN12p8nPevtqc/Z+FhCvor3oaOX6/G6bVijiRP4qLGXcPkf
         lmtlGpA+IH+pUoGKGxtHE3TFR/XcisxHqawsfoIQP/6QAqnxClSSHwH2MJJsFxlYOuQl
         e8YOX6pnTHfzBmuiSitkMlYWG7GmYwUoIE87ntjnhhuvB6iJkmSEBO8XRViPdC+zavz/
         nezmAmt72p56CUMlGmJP9OHYcH+5zvq5d7t9yHPFc5/eWlfiNSaXLt/QVdKicZf02vwN
         T7efh9czrCHJsjT2OMadWQHF2OQciYvrSgKXOWc88+KKp6K9fY0XOMfbt3QuxfAbUeSc
         /ZKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E4xysODT;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g15sor45856747qkk.161.2019.08.03.08.53.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 08:53:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E4xysODT;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wr1/jf7OC4N1CyD2pZrJRAsqKQhTrW81tkA/dMeoZYU=;
        b=E4xysODT5QEs0YiJh/6lyT4EBx4B7Mz7IMg6xczGcQ0G9Qk2AtE4TXZ+GCBgFJDEi1
         lLnFymeOoSvdAYvHJIdCSSrgbeDE4a17sW8u6K0mHvhTIQr7wv8IU/Sst4zTTu0Ui9p9
         jfnV5m2JmluBR+fiHIHyCypa6MemIx71M5jmKx6vtYPIEIc/gtcjHdvjaf5qkicR216B
         vr2TNHeSv9J9+fUNK7YQ/gOyrhWAGf5rfXuyH6O/uIOIbbVZkbs1h8vugk98ksEkGk+E
         kSQOd/o+FqbgLWKvjIyIdPT1Sa9ivX+Vce/lqYQCUaRKFWaUnKiHZKnPlvGognn7X6L+
         Xw7Q==
X-Google-Smtp-Source: APXvYqxgFYSi0U8M7Pxq58YMG2KJi0fk/qfGLpdfgkpRW+ewtu0h1e0nP4F1pryg35uOv1I+y7chQA==
X-Received: by 2002:a37:6085:: with SMTP id u127mr96259447qkb.25.1564847631510;
        Sat, 03 Aug 2019 08:53:51 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::7cfa])
        by smtp.gmail.com with ESMTPSA id r205sm38568262qke.115.2019.08.03.08.53.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 08:53:50 -0700 (PDT)
Date: Sat, 3 Aug 2019 08:53:49 -0700
From: Tejun Heo <tj@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-ID: <20190803155349.GD136335@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-3-tj@kernel.org>
 <20190803153908.GA932@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190803153908.GA932@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey, Matthew.

On Sat, Aug 03, 2019 at 08:39:08AM -0700, Matthew Wilcox wrote:
> On Sat, Aug 03, 2019 at 07:01:53AM -0700, Tejun Heo wrote:
> > There currently is no way to universally identify and lookup a bdi
> > without holding a reference and pointer to it.  This patch adds an
> > non-recycling bdi->id and implements bdi_get_by_id() which looks up
> > bdis by their ids.  This will be used by memcg foreign inode flushing.
> > 
> > I left bdi_list alone for simplicity and because while rb_tree does
> > support rcu assignment it doesn't seem to guarantee lossless walk when
> > walk is racing aginst tree rebalance operations.
> 
> This would seem like the perfect use for an allocating xarray.  That
> does guarantee lossless walk under the RCU lock.  You could get rid of the
> bdi_list too.

It definitely came to mind but there's a bunch of downsides to
recycling IDs or using radix tree for non-compacting allocations.

Thanks.

-- 
tejun

