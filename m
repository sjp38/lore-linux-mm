Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E32FC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:06:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2018220866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:06:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2018220866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9AF56B0008; Fri, 14 Jun 2019 11:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4A7F6B000A; Fri, 14 Jun 2019 11:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ED0A6B000D; Fri, 14 Jun 2019 11:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52DDF6B0008
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:06:28 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c6so701963wrp.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:06:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rhiq/ipt440J0RPVtOOtDaGx/0qhJtZOYaXbUu2kyLg=;
        b=Lp75Sx/ARZCst050sARtydDQZtHJ3oE3MKhbrupxslCk2GiUd8rgshHtVBGzH25aBK
         m1VPbtagMUIoaLJbYfIoZYHpVWyBrzGKjh2q1+BuUbxYxVPU7kLLQKrA6M4J5i6T4ZCV
         R59Y1ExJ00yjS93aB8FHHkH3rWgUnC4iYQ9Zhmib8MGYH4GxRt6lo6/1TWhjKTK5s3Z/
         3dC+JX5Vj/CQcCL5Bazxa66/Mij8xtQ/EWmcTFmzbUJIoH2VviIRn497ambSkHdHDTrQ
         t6q+AvU9IfcwlOJVCGjfMlVajT71PT4+9+xf66P7Ty6ltBb0R76nVCT9UEP8zA5e+Lfe
         gBwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXSiPPYO8Kf4dABavzgfHMo1A4Tzk00+hfDS8Xc6HVXU0mb/stl
	mmKc9SMUY6g39bM5JSz5fWSfUTC7/A3BupNE09+bmEazddVbYJMQ+9zZ7Ci5mASfgBbr3qEfXGR
	tT4ptYcETh1d/MCeTxbztbEsScxRpk9VVI3O33xNW2RF7obENMMcEo4uAdIW+C+aQWw==
X-Received: by 2002:a5d:4843:: with SMTP id n3mr12913080wrs.77.1560524787878;
        Fri, 14 Jun 2019 08:06:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQpRXY1XPhV6QHMGCtD0/5/JBXHcip8kx/lIkvm23K7WcMFZ4OGt2nl8dc+lPCxZRJFfj9
X-Received: by 2002:a5d:4843:: with SMTP id n3mr12913021wrs.77.1560524787255;
        Fri, 14 Jun 2019 08:06:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560524787; cv=none;
        d=google.com; s=arc-20160816;
        b=p4Db2H9yp+VdxxeTuH1ZXHIRNcN1gJeUEWLxjjLugUDxS7aySEa7amhez3sRODTu8M
         K5luEDYslYH+1cey5Gy1/QTKNB3ZYmL/smnWmOcFEoC7/iFOggXQSCmK4YfClGv3PrT+
         FvpAkUL7s/SR0pwqh+u0YTaAtr0kXjQjFRqdkXO7C6wlihaLnxiNTDDbbhTQOrtxf4T1
         7BDLqfBWSF/c7/xmqH7BX6/QNDAkwkXAmLrgIMeUdMvFdPyYjc21tdfcYW27csaknnKp
         6mB1lbfQIXSGZxcU2fmGWH/AG0mbUJf0JTEUbmNZNw5IzQmtjtjrnVZAI0/K74FA3XA9
         2s7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rhiq/ipt440J0RPVtOOtDaGx/0qhJtZOYaXbUu2kyLg=;
        b=aT2MT+IKmOnlmklOBZlihxlJ2hfsyCeLhM2SKF4vvIyvhsHzSoztJfr5AaAPdaSXXa
         rasG/hyn8HpcJ1dPVDe8ghH7fLzTS9O2pgN5UbIyiRY8cjocyw6Lqf6oYK4cT0NutMxT
         f6kIkIi5RvTh4Rhd6Up75Y4UOABncK2sXaFAtV/NZzcusky8DRz6mLE1JtjhaDpyyQZ7
         i8OGdt/LHNJRPgNizQnphfXZbyCm5HHTOjJCDiokCa+MrGRQXGeOXuOi6spoOlfTQPMx
         f5DJaLy2jn7InIEXu55dYlJGpD19nIZ53H2KoZIoNNhkEaqX2zv7QP++0eGIj/lI48fr
         Z8zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q4si2746852wrj.148.2019.06.14.08.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:06:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 9BFFD68AFE; Fri, 14 Jun 2019 17:05:58 +0200 (CEST)
Date: Fri, 14 Jun 2019 17:05:58 +0200
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
Message-ID: <20190614150558.GA9402@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190614134726.3827-17-hch@lst.de> <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com> <20190614145001.GB9088@lst.de> <d93fd4c2c1584d92a05dd641929f6d63@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d93fd4c2c1584d92a05dd641929f6d63@AcuMS.aculab.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 03:01:22PM +0000, David Laight wrote:
> I'm pretty sure there is a lot of code out there that makes that assumption.
> Without it many drivers will have to allocate almost double the
> amount of memory they actually need in order to get the required alignment.
> So instead of saving memory you'll actually make more be used.

That code would already be broken on a lot of Linux platforms.

