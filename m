Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40ECDC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:23:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C996218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:23:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C996218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B8768E0008; Tue, 23 Jul 2019 13:23:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 868708E0002; Tue, 23 Jul 2019 13:23:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 757E78E0008; Tue, 23 Jul 2019 13:23:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4102A8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:23:38 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v7so21059783wrt.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:23:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Zs8bXuZfeKkQ3YIUIjU1SAG8QG0cqI/PLt5qxITP56w=;
        b=ouLjx0wMa7mUXsFOH6xSf0PE91hJoB6fVvwQhPCgGkq/ylmg+Vywr10BgGnFohyYse
         AJBEEd3ezGYEe1PkTqA5H9BYH5Yde/YM4rDZlWoiN7phllrZ9nJuXa459svogzapIcbD
         z5z399UnmNLFcAqug88tWWf6MB9YWimHe+TQH+QTHa2cBjofhxWG3m/qEbczKBTpJ+GS
         K+FMb0vhOTjj8tQElZsTo24waIR5RpUcRiNcg3jY10Yx/8RKGYjzzLLgGw4yQt8UouZk
         zK8IPGOOMRe0FgCOLXD3JulXcUu/WXaJ25lG+wBr1xDBaMcQbBCFXX9JjAJmK633eN5W
         Ev1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVasnDInXwfHXRe9uqVWObiZFyeggj2XsgnEsWOYt3J042zEgNC
	rI8H4u2eTQzwxJgEyxOaxtrfP764rQ5tz4mfM1C+utWtv/ri9Dm4IrW4aun4sVD5qRofy5jpIDk
	oLZdPqvnDpxZGaB+L+U2bgZD5xCENCyDv//9YuGhIGpC5f0Jz9swXHq1QcSBKA6J++Q==
X-Received: by 2002:a1c:b68a:: with SMTP id g132mr72617125wmf.66.1563902617842;
        Tue, 23 Jul 2019 10:23:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNKGhcQOAW0Xs8aUW884X4gcSpQRfu6AIB1OR759C0EqU3LjyGbSokV19/FkSIfK9meHyN
X-Received: by 2002:a1c:b68a:: with SMTP id g132mr72617097wmf.66.1563902617096;
        Tue, 23 Jul 2019 10:23:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563902617; cv=none;
        d=google.com; s=arc-20160816;
        b=lJySGP8q+OZ/BMdCth3I+sodNCmZUkRwFxEoA3io7OG0NgI9ACan91AqFXvOJoBk2K
         zB9H0vcKz2uQoAdcQgk4He1vij+i3FMFAVLMojClphJvwnMtBtw7kAzqp6XI9R8zDgUZ
         H3Kst4mwxCJ80e9ueWCE0cd41fd3D+5QzKXcIi8ZxBGJ7cq5FUIsXz/aFs8WycAHXCNf
         dMH5FD1UuAuw88RH/5MRADYWT449U4SWD/B+Ez8+ltkd8OgPs3cCkFJ0O0oypn5zY2w+
         p3EF4xbN70VvW4QL2WrqVipbpZng5nQu8hmxZOZYwVEB7AyRIJ4KzSm9SaSzmuUEWuLn
         j/nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Zs8bXuZfeKkQ3YIUIjU1SAG8QG0cqI/PLt5qxITP56w=;
        b=xTTQrKu3+jgqOOZqhbQm20ZlESyx3osZV7NZEp0M3pRTP4ZKuPwJ1nPDbKGvut2Xam
         Z7V0G3XYCFG2c/pfnASGtG2u76JFulWDKn2i21KzWjkKuYSf08eQBS5hCmT6Ld+II5ns
         Bi3bJB+h9ofHqVgLoc9P4Ldir0WnAo6KL2daLYfy56BHlFJFKdZIEe+uoYTvzXYpGlG6
         6DvFWX9WS5LM3Np41oyclrd/8d1k2/MruTi1PmLr/Pus6WIgjMw2cS96FE+LaM5ebggq
         qOgBVpghEXAAIuUhsU661X2/k84OLpo1rOWAEJhY18nPObd83qplPGEYXf2sAdnOGfli
         a0oA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h9si34403494wmb.97.2019.07.23.10.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 10:23:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4F84E68B02; Tue, 23 Jul 2019 19:23:35 +0200 (CEST)
Date: Tue, 23 Jul 2019 19:23:35 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
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
Message-ID: <20190723172335.GA2846@lst.de>
References: <20190722094426.18563-1-hch@lst.de> <20190722094426.18563-5-hch@lst.de> <20190723151824.GL15331@mellanox.com> <20190723163048.GD1655@lst.de> <20190723171731.GD15357@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723171731.GD15357@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:17:31PM -0300, Jason Gunthorpe wrote:
> That reminds me, this code is also leaking hmm_range_unregister() in
> the success path, right?

No, that is done by hmm_vma_range_done / nouveau_range_done for the
success path.

> 
> I think the right way to structure this is to move the goto again and
> related into the nouveau_range_fault() so the whole retry algorithm is
> sensibly self contained.

Then we'd take svmm->mutex inside the helper and let the caller
unlock that.  Either way it is a bit of a mess, and I'd rather prefer
if someone has the hardware would do a grand rewrite of this path
eventually.  Alternatively if no one signs up to mainain this code
we should eventually drop it given the staging status.

