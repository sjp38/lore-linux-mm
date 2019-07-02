Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A60A5C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:35:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61AE72190C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:35:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l01hbVKK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61AE72190C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E289E6B0003; Tue,  2 Jul 2019 18:35:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD8A68E0003; Tue,  2 Jul 2019 18:35:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC78C8E0001; Tue,  2 Jul 2019 18:35:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 935916B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:35:38 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o16so264984pgk.18
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:35:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TxBrVjyIeN7nwx8lCxOCed1iNpKjH1qpjg0sErVxOlo=;
        b=FnFFRE4m9ZzXuSfrRJgoSAaWkMCnIxlclylUs62lgkpbuxUoRWl04JodcFBemeQuLB
         /qHOL4NjK+3MNNWwBGK9yLPHrnguY9/+6zEiUekpNGHqXY0/sWDXiTAUAJ/qmg7uXpX2
         Yj31XYZbgi09sZFUmJ5TvZTbdOc17Eqfw4/OJQ+d21nm6E/AYkIDuDsz+8pu9DP67juZ
         /onNeOQqukjFPz29Gi9i4rb/fwFoD+WDMghLg+LSSA6jiEMom6YxVflLZM7lkX0v5ib2
         /s+P6bqWVC1s3PzbN+7AuELRuMtNa3hpnrhxG1meYDS0IO4Mgit6EymrXGVpAAAeGfXE
         o8FQ==
X-Gm-Message-State: APjAAAW9Jim1yQuGEfRGL/DexRKqdNHwl3CuAbOiNtAw2+xTUr/to8qZ
	ncgr3W92kmQI7HTI5cHsuN3J9JmY34nc5kBD8EfuJSAaqiCRltMDgwlPqJGpx4fRd4mhJXr4+vi
	uVmPEkdVx4K/j+sqgeT5zd3ZGeAD1LPkNn41Nz4PaCecDP/DfVdt09R4U9F7xr3lCew==
X-Received: by 2002:a17:902:296a:: with SMTP id g97mr37270489plb.115.1562106938295;
        Tue, 02 Jul 2019 15:35:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhYk14lgTWC0TBFiDQtqfZXN3MjYtCHBw9N4pzfK4XTcT5oNsNH0zn3Ez75chSMtmIYL/j
X-Received: by 2002:a17:902:296a:: with SMTP id g97mr37270407plb.115.1562106937286;
        Tue, 02 Jul 2019 15:35:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562106937; cv=none;
        d=google.com; s=arc-20160816;
        b=eD+p33FkZ2FAhlBaGCE2Dcn5VpqFUo+2E80ggUFq0yqpQM316iq/0dQc0JDQ/Ql7yP
         0OUlD/yejVHJae3hFJXhXmOhZW9b1Qu/VomQdW7xOPFgkK8HA+mREXS+B/Y2durbF9A+
         VRvH4vfiMDv944M19untnKxxIQ3PwPaWg4NQFbSfEyOjP6qX3tRq3I5maqTaZ4g3f2y8
         rVNfV8RgsBX+hJrOqSYed7Fov5WYSMYyJmVNSSXiqDL9O8YtG0ACiaDep9u0K7jfoHbe
         xQPGunvZj/AhZ6nbCuegPHz1/y2uzSzqRSiZDIuE9I3VcoKznkSoFmSwCWUm5MrPrWrl
         s4MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TxBrVjyIeN7nwx8lCxOCed1iNpKjH1qpjg0sErVxOlo=;
        b=ZrEHOvAj2ze3tfPo6U3AecDM9BvJAusI4zqwXMjOW/QJncww9Sfs5XLjbdpspI25Kf
         zJv6aaOXdGZURBNughFIPJR+eATPRtNxA/zdUjmk+rCB+2O2WzRP+5PhC9COdmFdZw3M
         FwLJVupYFDwZk1QMBlj0wFRF+a8dNQDWcLcM1tEKG0eccERhnY9i3DtN5qogP9+YrxXh
         IPZZ2Ypi2Er5XABI2FCshIcwD2bj3nIlnMRgLkyXUDJXRZWA4/mTaaNDBAMQFc0dLMoa
         L3x8igSRYIm+ZySfIEhy3VxXozrOPhvHXhPM04jRkYl8qFWYzuKY+J7YS2zjDTTNDheB
         1uQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l01hbVKK;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r11si4873pjq.108.2019.07.02.15.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 15:35:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l01hbVKK;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6F38A21904;
	Tue,  2 Jul 2019 22:35:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562106936;
	bh=c/MyoEL1y9iSRH8tUqhzcXV9ntk3My2ap/3Dn7awyKw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=l01hbVKK1DS91crh+dWLCuA/4HwJhhjblV3ZmG7+ToSZt2H6+9chb5C6lWKcVbpZT
	 6yf7b0ESc5qYx1xKDTnqLzeOjjZhZFZwE/7x1lR6/PQ/5qZQPNx1I+vWXKWbwacqes
	 0uz8JuzySX1Z2Xp+A47oGKzrXsLwsUNXRd+bPFwo=
Date: Tue, 2 Jul 2019 15:35:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
 =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Ben Skeggs
 <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Message-Id: <20190702153535.228365fea7f0063cceec96cd@linux-foundation.org>
In-Reply-To: <CAPcyv4h90DAVHbZ4bgvJwpfB8wr2K28oEes6HcdQOpf02+NL=g@mail.gmail.com>
References: <20190626122724.13313-17-hch@lst.de>
	<20190628153827.GA5373@mellanox.com>
	<CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
	<20190628170219.GA3608@mellanox.com>
	<CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
	<CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com>
	<20190628182922.GA15242@mellanox.com>
	<CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com>
	<20190628185152.GA9117@lst.de>
	<CAPcyv4i+b6bKhSF2+z7Wcw4OUAvb1=m289u9QF8zPwLk402JVg@mail.gmail.com>
	<20190628190207.GA9317@lst.de>
	<CAPcyv4h90DAVHbZ4bgvJwpfB8wr2K28oEes6HcdQOpf02+NL=g@mail.gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jun 2019 12:14:44 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> I believe -mm auto drops patches when they appear in the -next
> baseline. So it should "just work" to pull it into the series and send
> it along for -next inclusion.

Yup.  Although it isn't very "auto" - I manually check that the patch
which turned up in -next was identical to the version which I had.  If
not, I go find out why...

