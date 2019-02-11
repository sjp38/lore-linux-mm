Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DEAR_SOMETHING,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 223F9C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC3BC222A0
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:57:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC3BC222A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 711258E014E; Mon, 11 Feb 2019 14:57:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BF448E0125; Mon, 11 Feb 2019 14:57:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2298E014E; Mon, 11 Feb 2019 14:57:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3CE8E0125
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:57:12 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p5so188062qtp.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:57:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Qohar+o4qQy6gY+kKJxq3zNhWX5Agwk79jDZi8L+b/c=;
        b=a1XezGk/oJhAsg39QIIZ7b+hRacisw8m6nMoirTY8/mttK29edKGz8281pn0FWwL0F
         OWtE5GRD6rq+v6ybcNooWV22wRLVRYgWDjYXHuptsyDeHe3bxy/eincKQ/W/Pf8COD1V
         9WAbzXbIb1cZb++2CD81obIDbqf4ERDXQh+ZMOzCRPeZZsbvRHRIM1F3OgF3Z8FEmWFO
         5JW2R3c3t8HRP7Bx/RA31I+JJMXpr7BXA69QUV0SbOIXlYY7jDGlDeo2344nPWogJdye
         DMdJS0QUHbnJY8ESeKFjmtjyiWtlIZdYBvzSE7uxAtc12oCUMjsECmV4CknLe/VhFT8R
         PIiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZByB0ARUF8zzN3GNsEYYbyKrAsnopms7cCBn05pnk3uAVur8u4
	K2VrB1WH660f79lXoqWQvXegbllh/99xitbTJtgkN/wEAXfa2IEDxY3OPNh0aV7+bKLpMeSGoHR
	HPHozdFwN4KA169Hpt2017bKX+Mdzl1k8qoaF5RjZnjOsOTYvp32jbXaAjabiUPSYwQ==
X-Received: by 2002:a37:390:: with SMTP id 138mr4681987qkd.292.1549915031934;
        Mon, 11 Feb 2019 11:57:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaYJLsqnV8qNN0JKmVcfVIjl8dsHiSgdoJy8uAO7xzBjDjgA2xQjWtE8g2fr8VxTiudIwnz
X-Received: by 2002:a37:390:: with SMTP id 138mr4681965qkd.292.1549915031428;
        Mon, 11 Feb 2019 11:57:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549915031; cv=none;
        d=google.com; s=arc-20160816;
        b=QNoqx+mCwwc/G5Xvlg7YbIn5it5eiGC6tTBEcU/rqw1v+w3G6U+yJC4pMx/38wrrPi
         taXnKPkN3xxxc8Ej33hLpjsBm1qxJkRJX2fIbnd7mpIJJ7DLbHy3M/k8qzZBU2a5sqaV
         0w/3XvOrRi3QbL0gFUigWSbfmi3QnmS7dcj4zpEPCuwBks8ZjWDlNWB01EpmkymUtmFH
         gIrbOxaMa3e13842sR037kcIOQ2UaK7rcnHzcDFh03NdztWSsatIcJmKBifGImUY0rBQ
         xWwwlCdyQnti81Ki/Bk50CxPz4TAdVlbyJTgwTXRbRpf19YfYSyTlMq8RjMP0/8uhXNy
         3ltg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Qohar+o4qQy6gY+kKJxq3zNhWX5Agwk79jDZi8L+b/c=;
        b=FKwSVi/wSqrj7tHbTeHs62NQLHptqHaFx+c8ZLsJyDvUuAuTMtokT5RTXpWY4G6ezZ
         xQDAS1KqgoL2rjdujq2V1GrZ+a+mbsycRcaEHzH6bmzyO1xeGrFTUrMw4M6tAiXjuyP5
         4thr9TjhwYB3luOYf8VB3TZ4GWJQFzmnQpY23RknyfWY25dhJ7VQH5+4V/85VbE60J68
         iX/kEqlUIUtZdXLkGzrh/COQtzTyvrnyw7MuR/xGdMcK1zmc2K9ERbK+I9Q/7oocWkHP
         5a5rFcpFbndloNaGP9445sMufk7FnxR7lBMNu89AdaJCBGUnITRWeK2qCkYzqG2jsP84
         53kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k7si1985705qtk.40.2019.02.11.11.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:57:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 90A54A7878;
	Mon, 11 Feb 2019 19:57:10 +0000 (UTC)
Received: from redhat.com (ovpn-123-21.rdu2.redhat.com [10.10.123.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 613048517;
	Mon, 11 Feb 2019 19:57:09 +0000 (UTC)
Date: Mon, 11 Feb 2019 14:57:07 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Krzysztof Grygiencz <kfgz@interia.pl>
Cc: dan.j.williams@intel.com, akpm@linux-foundation.org,
	dri-devel@lists.freedesktop.org, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	logang@deltatee.com, stable@vger.kernel.org,
	torvalds@linux-foundation.org
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
Message-ID: <20190211195706.GE3908@redhat.com>
References: <30d86b36-8421-f899-205e-4b9c6a5fcc9d@interia.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <30d86b36-8421-f899-205e-4b9c6a5fcc9d@interia.pl>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 11 Feb 2019 19:57:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 10, 2019 at 12:09:08PM +0100, Krzysztof Grygiencz wrote:
> Dear Sir,
> 
> I'm using ArchLinux distribution. After kernel upgrade form 4.19.14 to
> 4.19.15 my X environment stopped working. I have AMD HD3300 (RS780D)
> graphics card. I have bisected kernel and found a failing commit:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=v4.19.20&id=ec5471c92fb29ad848c81875840478be201eeb3f

This is a false positive, you should skip that commit. It will not impact
the GPU driver for your specific GPUs. My advice is to first bisect on
drivers/gpu/drm/radeon only.

Cheers,
Jérôme

