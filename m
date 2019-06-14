Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D80AC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:50:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1984421537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:50:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1984421537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E6D86B0008; Fri, 14 Jun 2019 10:50:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 870706B000A; Fri, 14 Jun 2019 10:50:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75FCE6B000D; Fri, 14 Jun 2019 10:50:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 270E56B0008
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:50:31 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v7so1149843wrt.6
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:50:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F48VYgM9J2J8awCOKcxbdTK+1rFodq9MDY/QwcK8W90=;
        b=AMJnGcHGGuXd5bmllYo8KUpiX9GMBxKODpV9k0DtasTqnf50lxWEkXTHHnzhsa7Sk6
         XVkIdemtuGKKGLLcfy56qNzUQzhpGUP7aR2gNJb2L63R6nhsDZ4k+gd7sNZhifJyWPk8
         txH95XRrmLfC8GNmuhF9FRFxEfbCB0Zv1RmlRcelvsZo7hpaH45iTvKUEMFh72atZAqv
         Pik0klLlPDtAxnquMjwDj8pxq0kVJDLaI8XYxGWo5tnIpT05LXUyftuepxg2UOkH7AGO
         e1f+VrOF7J9lr6ZibsrlKlOOERUZEmkxSxAskmBhmvPmZrac+ZTAW+twgAGRAuVhvN2t
         zutw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUYzmmkB2y2MYoj5h/alkGT3D4dmEySr/qqlB3x193ESc38dmLx
	5sZWP6lsKlnmX9Or8uq0IPAwwjeMjGL43yhkOX8uG9ZGCJGDFl5tpUJ+HfK72qG3QaEQZb/4Sw6
	pbzgRPHJVIUrIEfTWTqDFGIukU7vgYBTO1vrT1zqroD0B0/bU0IVcg9110+ttBlVRow==
X-Received: by 2002:a1c:4956:: with SMTP id w83mr8122095wma.67.1560523830737;
        Fri, 14 Jun 2019 07:50:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfCXH5DpZiJK8d09tR050TSAu57AonfCPKcghU4KoFuXkRTYu47KKHpwKH9PuCkUnen5Bl
X-Received: by 2002:a1c:4956:: with SMTP id w83mr8122068wma.67.1560523830117;
        Fri, 14 Jun 2019 07:50:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560523830; cv=none;
        d=google.com; s=arc-20160816;
        b=hTyWE5TPrA9ogDilqB4g8l7vf+Li1pyT5vSsdjDrtFKpJ3Vf9h1h7pjFm7URLNGUGG
         w5LIETIz3YHgq8pZQmmDJhMobPZL9+Rcpx8KzVET3t+xP6uNgMtPkN1kjwcpTHnFP+kl
         EIq+yDAT3nl5N8T2HuM05TV378XscTxYajchgXwHBgU+EQCwFH+x5keeM0C7VQh0jLUC
         Tg2nm8hvrZrBK5efaU8VvfmEQHY7vyX6g+wddD6HjTIs612XRo0cb0ZrFEh8MDwBAiQp
         bE4skwB/L61+d+zTK0Yp/XWJIRjJaVOxDTwxDMS5rFdTZdcofJuFEWy+iKJDWNjj0kJW
         7xXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F48VYgM9J2J8awCOKcxbdTK+1rFodq9MDY/QwcK8W90=;
        b=aYCvUyCrXB2CkQoXNWcHSYFMQZqQo84t2+4vAbCwMJhNnuYj6CbA/9miCdPOSUKOV9
         +iYUG3UuOemNh5Z1BSdVJff4M/kn7ychhgjh9wHOnQz0n5phb+EMDsBKob3kUdpgOAn2
         aF+LFbfsJkwWeZ5AfEKZ4zIWDlKLM1sM1QW3eun89OtwAmQ/aDhswrSSPqh1T3IEgdsg
         k6gnXLZ1hql7Vv5xHBF0Zay5fyqYeeTrx+8XHDUHl1FIR3uzw1b7tLUJ4aipvU8gES9O
         /I/EsYIfirFNddzKn+0oByt4q9kbbxtB4d3DAONCe21P3D2zGvzQUTwGGxTzblWTsWR5
         Qp7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c13si2066650wml.29.2019.06.14.07.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 07:50:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 94A01227A82; Fri, 14 Jun 2019 16:50:02 +0200 (CEST)
Date: Fri, 14 Jun 2019 16:50:01 +0200
From: 'Christoph Hellwig' <hch@lst.de>
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Christoph Hellwig' <hch@lst.de>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Message-ID: <20190614145001.GB9088@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190614134726.3827-17-hch@lst.de> <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 02:15:44PM +0000, David Laight wrote:
> Does this still guarantee that requests for 16k will not cross a 16k boundary?
> It looks like you are losing the alignment parameter.

The DMA API never gave you alignment guarantees to start with,
and you can get not naturally aligned memory from many of our
current implementations.

