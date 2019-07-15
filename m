Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AF98C742D2
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 02:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2090420820
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 02:49:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="QG6qimnZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2090420820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB4ED6B0003; Sun, 14 Jul 2019 22:49:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A16386B0006; Sun, 14 Jul 2019 22:49:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6B36B0007; Sun, 14 Jul 2019 22:49:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 238A36B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 22:49:02 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 9so3486422ljp.7
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:49:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0xXZnp3zLEv9/8rZrVJ8Bb1hgH0mFVq0ktioQL8IoBE=;
        b=S3YuQvgwLulTu3eddqKxnJncZB0o7aV1UqNLZ1aT20xMr7G8lqfrFuPmx1UULJ+58I
         LT/Al83EZVKaTWNg09216+IfIjH81aeEZr6H10dVI32DGsNBUvFNHyS7QwdVwZbBz8LB
         /pHNyuevkhyPDNsg07iSF7BX/VQM/w4dXeY4i1iElEAJDr7Le8AZExx3agmz8Nq/XJ4g
         TQ/8gsgYGu7CJbbOqRrsUKdICFs+z/lnrf5/CHD+eb4jHY6WRGI72Jh9IrDMZwhyTCcF
         pIXAzaWnBLG80fL2jBm/Z9ukKgupcmZkhOFK5eM/jY39+vWISKz52ebXmafjQP7qMvkG
         CQsA==
X-Gm-Message-State: APjAAAW1XZrDKb8E4GU3k4rBydUzuo85/cN+lMEBZT4hBedZSdObDCSr
	QhC66ywXp5hap/Hkv5g3FWaRaiHYcfLZtlvE6ANghJuLHCpqCt0LrncdzJTPvkbOtp89XkDmR8X
	radRfiqku4prrD7RZP0DkuEABYcEIDed7+Soa9hSawvq7UVA9MXcsjQR97saJ+qBXaw==
X-Received: by 2002:a2e:860d:: with SMTP id a13mr12562034lji.215.1563158941325;
        Sun, 14 Jul 2019 19:49:01 -0700 (PDT)
X-Received: by 2002:a2e:860d:: with SMTP id a13mr12562012lji.215.1563158940455;
        Sun, 14 Jul 2019 19:49:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563158940; cv=none;
        d=google.com; s=arc-20160816;
        b=QoXDbtx+zocq97FWlOK/hdVPPI1qK7DUuG9w56vyOfQqh++jH+NfRWeRahbTa9cm5i
         zWMMSi1f2vVy3vB/3CCs9BJHB83woXdbK0+tjOzIXcjNtYpar0fXYxWs5Q0fKT3RzTvh
         PRac8LQpN5R+1WxgT1AGw7r4POB7ZzK4pfGe/uyM751KNkHjHpWTOpSTLv2k81Aed+dC
         IWsCt50Fp1/vmGrz++M1txItutCNs4Gs0sY81aPU8N3DeGoGG8jq13+hmfw+M7mp5D2N
         URCqZT4h/A1HcT/D6FSGS676BZAnhU2sV1y+dO20LSHOMkVo3Y+8RxGU1cjumtmzwjdB
         ZkZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0xXZnp3zLEv9/8rZrVJ8Bb1hgH0mFVq0ktioQL8IoBE=;
        b=lWLSV5DvYy6D4mg1N0Ig7W77Vzw3oUyq6bxLvchqMe55EbyTbYnLsYpWHBlk/0j+C4
         zBN7N0OaTnlBFFhcJc1oYfL8wOEdYDZ/RJzUZzr53gUk9MG8weR4N3akATL092f+C0sC
         vEaZ5UKYPt4fwglcohZz75sO27/GZg06TpOlvDFWhIYrI/9z2JZCzwdVYVWw7XLAfhrm
         R4KFgaF26noN3NxuhOXKi1yyfgXgIG21WR3VVEiufUd8Sk+/2dXJDGACLMZbn4fTAVO5
         I9+K4puf219WobtmMG8t+y6DfiGBhTbwJDV1gsoQvE18uvnBFzyf9J1EoNrLJ0kIc1F+
         QSzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=QG6qimnZ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v9sor8265421ljh.19.2019.07.14.19.49.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 19:49:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=QG6qimnZ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0xXZnp3zLEv9/8rZrVJ8Bb1hgH0mFVq0ktioQL8IoBE=;
        b=QG6qimnZ0OuOr18TPPyD1ZpsfC2oaBrHXD55BhiSP6dw+mQqPSGsIUy/Yf4/KOcnWu
         3PMYYqkRk/B44HHs/mOcE5iy2y+FDx49TCkO+kDXoObGp0hcYXLYXFAlMjRw25zjrKgL
         tjFllJ7em2UwShT6KqGZwlL9Geykn6fnTBnEs=
X-Google-Smtp-Source: APXvYqywyJvt+YQ8Eg0rVxXKNaFlFMRze44z/2hsunJNfbZAeVON3J97C0yCMb7eZUYLX8qXA2LF+Q==
X-Received: by 2002:a05:651c:87:: with SMTP id 7mr5334073ljq.184.1563158939459;
        Sun, 14 Jul 2019 19:48:59 -0700 (PDT)
Received: from mail-lj1-f177.google.com (mail-lj1-f177.google.com. [209.85.208.177])
        by smtp.gmail.com with ESMTPSA id k8sm2859968lja.24.2019.07.14.19.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 19:48:56 -0700 (PDT)
Received: by mail-lj1-f177.google.com with SMTP id d24so14558461ljg.8
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:48:56 -0700 (PDT)
X-Received: by 2002:a2e:9ec9:: with SMTP id h9mr11885151ljk.90.1563158936002;
 Sun, 14 Jul 2019 19:48:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190709192418.GA13677@ziepe.ca>
In-Reply-To: <20190709192418.GA13677@ziepe.ca>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 14 Jul 2019 19:48:40 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgHKrYEMDbA9CxZ2Sw8JuW3=Wxr1fZo+EvXXLhg4iUOmw@mail.gmail.com>
Message-ID: <CAHk-=wgHKrYEMDbA9CxZ2Sw8JuW3=Wxr1fZo+EvXXLhg4iUOmw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull hmm changes
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Christoph Hellwig <hch@lst.de>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, 
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 9, 2019 at 12:24 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> I'm sending it early as it is now a dependency for several patches in
> mm's quilt.

.. but I waited to merge it until I had time to review it more
closely, because I expected the review to be painful.

I'm happy to say that I was overly pessimistic, and that instead of
finding things to hate, I found it all looking good.

Particularly the whole "use reference counts properly, so that
lifetimes make sense and all those nasty cases can't happen" parts.

It's all merged, just waiting for the test-build to verify that I
didn't miss anything (well, at least nothing obvious).

                      Linus

