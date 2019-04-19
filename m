Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A4EC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:06:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B92A217FA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B92A217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE97D6B000D; Fri, 19 Apr 2019 03:05:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C990C6B000E; Fri, 19 Apr 2019 03:05:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87BF6B0010; Fri, 19 Apr 2019 03:05:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D98B6B000D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:05:58 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t9so4130899wrs.16
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:05:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G0ktsxmIuC50UpiTSioacc22vKjUWwFoQiG6XDQKEXM=;
        b=jf6PFXk4y9zWMBHj1Js98pxd8PXnAJiih3WmAwF+vWHmH9UdBYt6IObYoB7dNi8ir/
         Tgh+C3U38jmqzR378zWES6ZYPwQiIAbyHbicLbRZVk/eVqXp0a1W0++Wm7BJuCMSwwPD
         iET5fCYDO/cUNS5st9DWaHXYrvCxqoDM9utCDafB5WO1Z1pBTwS47Vd8uM/9aiS2auU4
         f4QEHhg650zgTHZj/DXsdJonnRmON9XPUlJIM0Qkr+W2tIaOrcrBhOW760g0pT7b6YjO
         D/krhAuV13U/dXhQzxrfDx24heQVuh8eZdAfcytSNZ8hNwgA+Espk7c9LPjnOHkmvTzy
         nb7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXcixd7PJxfcRnX9Tizz2KfVsgCvAzko0qKTleWZ0ToROODsKeK
	RTrWzeN9HCrmhIxifjam6Lg5zNPhZ27tKy1R/CICFiITpb+fwToZxFtkyLnUarE/l69upAJNde0
	mgPW+FLavNhA3FmwLrIR5ppK+LMQWCKCm91REznv+N/EUa1N8DCzjqRJtMg+OP6QoiQ==
X-Received: by 2002:a1c:be0e:: with SMTP id o14mr1596186wmf.118.1555657557960;
        Fri, 19 Apr 2019 00:05:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3ZqOpS/Vez/AUZrzmLNijU8FGXOZEpC+kGpLCmSoOByNqcuUrrNlxGpSzmUVMPSTz2/Nq
X-Received: by 2002:a1c:be0e:: with SMTP id o14mr1596140wmf.118.1555657557151;
        Fri, 19 Apr 2019 00:05:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555657557; cv=none;
        d=google.com; s=arc-20160816;
        b=aSeXvaCAP2474P7sDYoJwQQLO/9A8NYK8t0GayFMOwEh2Hrk6lhOsXsB6KqWciKB5G
         v7pcht99EptkE0fNKE6QcHbVJCzm2t1PbIIujXAA5szdzoxe0Jx5Wld0O0n+4CSh9sux
         kYFgihPd/RJcGQh2kA0WMirJAoXc5qtJkIjmTJlMCFS/dBz/YsG+UmKNG1VEWC0nCKib
         QqPhbT0//EfRXDhnHruSmi4xtRkwFFCJtXOEhQupCW4slZDQzSesQiK0WX2EmMIGe6ge
         qPT6DaiZA+b4151CCFtlWrsSF5rpdVpIw2SxhLLj4F+wKz52PUGW65me1TkYfvfYtXDL
         gWXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G0ktsxmIuC50UpiTSioacc22vKjUWwFoQiG6XDQKEXM=;
        b=vw+EnZI4v17nkpOWtawDpquir0iJO2BLdLGnAhJeMOvdS75mmSlEfQxR50Re+mKMNw
         OZb4QNnBZHrTecuhTkWJ6n2hxAOt2mSx1JoshhR1NSmoVxNVbtiRjmJbIN6g4S4Y9bwr
         uWOiCcuDyRHbckkO32r+OvFx2kEMz+d1vlAl1vIO0ODg93GL3TVWI3inkSDfPZI/kCC+
         cHKMRf0uJ0QXhJ40HlS4FmopC+otJuQiGpjfBNgMkXWIWedXMvcwJ5sHG8ZT7mLSneoR
         r20sFZiLzNfBdpTyQOXiEymrrxbdeq8U2uk//EB6hpxPoVbYzl5+CJLa4DVbI0314G+P
         tsRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c16si3279712wro.273.2019.04.19.00.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 00:05:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 90FD068B05; Fri, 19 Apr 2019 09:05:42 +0200 (CEST)
Date: Fri, 19 Apr 2019 09:05:42 +0200
From: Christoph Hellwig <hch@lst.de>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 12/29] dma/debug: Simplify stracktrace retrieval
Message-ID: <20190419070542.GA21317@lst.de>
References: <20190418084119.056416939@linutronix.de> <20190418084254.180116966@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084254.180116966@linutronix.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Please fix up the > 80 char line.  Otherwise:

Reviewed-by: Christoph Hellwig <hch@lst.de>

