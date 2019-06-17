Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FFCAC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:34:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF6DE2238D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:34:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF6DE2238D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BFA68E0003; Mon, 17 Jun 2019 04:34:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 549118E0001; Mon, 17 Jun 2019 04:34:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E9028E0003; Mon, 17 Jun 2019 04:34:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4B4D8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:34:13 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t141so1346430wmt.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:34:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KVPyABFOupIEQSwIksd7RgBMD3OwMKo6EiczyFkgofk=;
        b=AGTWuhBfe9bFNoGppHkFCVCpgw/zSM1upwJu4RR4cIqGynLmcixN0GZX4PRlK9nogj
         jju10XjtNvEYXWsw0ZDpeB/hlsexsOBdhwMa8Iit2H3uuga34gp44Nlk+/bT1eRxlLyF
         AEqwT7d2gW7uDi46LQIn4GvM7cVAPcshcaBWzn7T1NOHk/elGeAYQ0ZAlxVT2DuwCceY
         A96eyNwaEdKHqVN/BpYhMbQv6tR1TBkRuUT8zsclmIuYXUVnMr5VwYPzqcmmSPJIIk9Q
         OHfy3UZYXRuFIDJOpmNkHxjIq0/+wqOig9xaI0m7p+2+BZ/8HAq6DYRZfwLVnoJw1IKf
         4KkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVbsDD84KeYtxlRB5gTrDcl0nUYoig+PhOXCJbck+soOg4p7jhl
	ajpxNc0n/HI8yJfFuFy4bE8tmBGSF1ok+CuTAA+pY+pN85Qa9NGku75wlAHch4zSvyJrAz0iXzD
	opC/Dlctxjmt/GQV8v+qC28AkMWV8GxTbFushgI8irCT75erqI+4rPM2VGbZodq7Q+w==
X-Received: by 2002:a1c:2082:: with SMTP id g124mr16968161wmg.71.1560760453453;
        Mon, 17 Jun 2019 01:34:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd0n3sqQXhLKpdv5fgeW7eQIzIh5+sFxArwcUcXxycImdQb5E+qySp0QoLhBPW66fAPDfS
X-Received: by 2002:a1c:2082:: with SMTP id g124mr16968099wmg.71.1560760452678;
        Mon, 17 Jun 2019 01:34:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560760452; cv=none;
        d=google.com; s=arc-20160816;
        b=q+avUBUVcTbs4DTreYQIntgbtIvK/Pbs6pFlC7sxYusahzxQnthz778wgj/xqJtFXa
         ZEKDlEI1sa84Z1rXumjyAPXDUokjUqJ6ApsxpkzkjsryDdsZ5NWd2TpHCtCWsQBy0Duo
         8U9G8NOybZFE0H1rWYskHQbGLO8TEZpzGOK1wV2cCmzV6o8ww/SWMEe4BHjwVuP7ExjI
         xCAZndvNoR15s85OBkYU0rsS2n1QVP594/B9UiLPCm/8QcosCtF/LaAVVqrNtmGDRjcN
         T4lFGRkHN+O3ISNZDMSPiUis43zuB6dP8UAhlcv0qcgGtYjA0f556TiDock5tLGlRow2
         grbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KVPyABFOupIEQSwIksd7RgBMD3OwMKo6EiczyFkgofk=;
        b=ucImHwX+gl3c79Wz+ubQ0Ey4paWrm3UjffeNkjAp9X6+Pw+8/GftNtPsrFipIkV0Oo
         8ECwHmkEp0caoQMWPl5x+czUKDbSxATWvP6q/0HtJuNIHmZYbD4eMJ5OoVelJkPPZAss
         9pmuAEc8t4C7ZPK66hsMXYQzoj1nO/LFoZMR5qT3ZWhSH4Cyk15ePkKUo403A5tEmcdI
         lSYfZ7e4EXepBCMej7KfQnzY63TJf/gxyQ+eAyZjurJA7TrmU5lVpjSLIlrgrft2FfyH
         O4BYYQbPH/hrZ+bV8/kb544h3aWJZRgEMti+4jSwNMzpc2+5Lpi6Q5XVoUaGRQ1FpCK8
         +EKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y196si4867222wmd.4.2019.06.17.01.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:34:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D530F68D0E; Mon, 17 Jun 2019 10:33:42 +0200 (CEST)
Date: Mon, 17 Jun 2019 10:33:42 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: use exact allocation for dma coherent memory
Message-ID: <20190617083342.GA7883@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190617082148.GF28859@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617082148.GF28859@kadam>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> drivers/infiniband/hw/cxgb4/qp.c
>    129  static int alloc_host_sq(struct c4iw_rdev *rdev, struct t4_sq *sq)
>    130  {
>    131          sq->queue = dma_alloc_coherent(&(rdev->lldi.pdev->dev), sq->memsize,
>    132                                         &(sq->dma_addr), GFP_KERNEL);
>    133          if (!sq->queue)
>    134                  return -ENOMEM;
>    135          sq->phys_addr = virt_to_phys(sq->queue);
>    136          dma_unmap_addr_set(sq, mapping, sq->dma_addr);
>    137          return 0;
>    138  }
> 
> Is this a bug?

Yes.  This will blow up badly on many platforms, as sq->queue
might be vmapped, ioremapped, come from a pool without page backing.

