Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D595C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:48:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09C222089C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:48:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09C222089C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 935D46B0003; Mon,  1 Jul 2019 04:48:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BFF98E0003; Mon,  1 Jul 2019 04:48:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787BD8E0002; Mon,  1 Jul 2019 04:48:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f79.google.com (mail-wr1-f79.google.com [209.85.221.79])
	by kanga.kvack.org (Postfix) with ESMTP id 40CBB6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:48:36 -0400 (EDT)
Received: by mail-wr1-f79.google.com with SMTP id i2so5410270wrp.12
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:48:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7ZYA6fUI1X2SHNO1Ia+3evZkOGzY3lvUDNE7zy6wa8M=;
        b=Q0gAceYIvjyTmFLW1c3/i5btVTpeVO1YfJ1dBIvW8MYflDnUoyWvDgmFBtuS8+NZwQ
         lcAUPDwGr7VrC6rsXnGr4sZupjLNRWeoI9wd1Cbqi8iRq3ULd4Jp4wBPjeN1ZwIK4VGb
         8c5SGFpE/m7uHjEAACk1ajh8wwe+elovk3KGbBQQwkVeJTmwU5qJFP2xyhprQAb0p/yZ
         wzJfZDCvsoH5/D33kEeEtk/i4zlr01Zeu8AYCN8V23OVqcYU6PFVsQHUPIJ1db1+z1Wn
         6f3pQJrmoFObGndjOeXPXFP6J05aJQ+PTajOPhpEDRcOFc9saPyNHydKhJnpdh3gctGy
         BXWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVynQUfqCVcAegVMGludEjD/Gue9+qGGPAt+qBI4TAsLbc6Nscq
	pPhqBiKimd+K0QQsbYwr/7CjBwXsQu4qlnqCFqJOhCfkQBOPq/GmuvX2Llp6vgq5XWWKol8yQ5F
	tkovyqiK1u/xPu7LNiiVpmesZ50XopEyfnbHw/hEq5c85e0cCty8biLYfieIuWUfAFA==
X-Received: by 2002:a1c:5f56:: with SMTP id t83mr15220244wmb.37.1561970915799;
        Mon, 01 Jul 2019 01:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhOkWDEfHiYzxgfzT/eYwqCcxdtstJe6Xmw7ZJi+V+1b8TdDXmFtBfj3PtxtPF4Xzpf1Qv
X-Received: by 2002:a1c:5f56:: with SMTP id t83mr15220200wmb.37.1561970914984;
        Mon, 01 Jul 2019 01:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561970914; cv=none;
        d=google.com; s=arc-20160816;
        b=Ti5VifII+YjkrZUNyHkqdO7MYnliUilYsxZJQj2RCk8H2tfZA390aTEBLXoBIDmByR
         bhETRjqtTuMFSQtfuP45umuW7QA04p0Yy6yFLBVaEOqLZIgJWIff+d4FpUyzL7HYWERj
         UCNQbKsMPMMQaVGF928nmgr3vZ9EWXd0immAeXota2RA/VO0gSWrR0q4fHDt061mADtT
         Go7O2ABMzdEfGK2w8pE0I+eUSFhlEp40+vv77e4sNiSJzYPCIkZ8CGlxs3MoQHig5kH0
         DF/nm1LmADGljPMbC+SU6+cBTavzL9AnPGxeBrjCHyoDfAbKXlDKxt7JEXKHLQvUXdrc
         9QjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7ZYA6fUI1X2SHNO1Ia+3evZkOGzY3lvUDNE7zy6wa8M=;
        b=Zzmqo9cs1v/pnzLfvuXkp2x2L+S+IhIaXFtcKtEyi4OJn03Civ0bNc2Nl4dUHkluW3
         5OtW9OxeJPmJ3X0JMK1SuvOBgECbdu/FOH16AJYdb7HsfGnw+L/1IvyyHFhqu1WORx0B
         6tr2TBZV+3TgEcCf+vZ8MxavlIBptXZ+q8pH1VvYg5J94P6qeOJyXxhkeXFFZbxuZmGs
         NcNNjlfOMTGTAHjvgkJlfOpoigUVQXe9DB5tYvrHTdteK4cuyjall0/8MejsIlBG6+VD
         i3LHK+eIAkHOXcFNbq4ItX8aSEnMc/wM9WwzUudCy4B4rll1E9wEOBkx/eGl53wzWfit
         XWvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u11si6915117wmj.197.2019.07.01.01.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:48:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id AC3E268B20; Mon,  1 Jul 2019 10:48:33 +0200 (CEST)
Date: Mon, 1 Jul 2019 10:48:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: use exact allocation for dma coherent memory
Message-ID: <20190701084833.GA22927@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 03:47:10PM +0200, Christoph Hellwig wrote:
> Switching to a slightly cleaned up alloc_pages_exact is pretty easy,
> but it turns out that because we didn't filter valid gfp_t flags
> on the DMA allocator, a bunch of drivers were passing __GFP_COMP
> to it, which is rather bogus in too many ways to explain.  Arm has
> been filtering it for a while, but this series instead tries to fix
> the drivers and warn when __GFP_COMP is passed, which makes it much
> larger than just adding the functionality.

Dear driver maintainers,

can you look over the patches touching your drivers, please?  I'd
like to get as much as possible of the driver patches into this
merge window, so that it can you through your maintainer trees.

