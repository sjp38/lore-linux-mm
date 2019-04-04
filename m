Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A347FC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65E4B206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:32:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="I/nIbvmP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65E4B206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04F686B000E; Thu,  4 Apr 2019 15:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3FD16B0266; Thu,  4 Apr 2019 15:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2E656B0269; Thu,  4 Apr 2019 15:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE3876B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:32:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g83so2411422pfd.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:32:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dRdt+9F2fFh2MhgOyplKH+n+b53N1s6QD7kx64loto4=;
        b=PI5ABwRthG7kPVTJFw5iFZNk33yjT877mE5jxlFqaSM3Xr1e86Fw+fleroWhdOMUZs
         NaAkCTxuaM09RKsx0KPlc2FkEtl2biBEiu4FRhQBAhRGGDhvPVeIbRsjBsTyALtIZyZe
         q/v8flhBFQIkipwtlnN5hApdW0+Hib7uyuCyy95UO+BGpqkCCjRNhj60Mps8jjPfEC/O
         WwPWiO4qdLC78+Z1pDpxV6la1m21h4GsWGFCnPC1fHTpTLeP3ww+xy3Wh+RjH6QDK4aR
         mFWz41eQ19FXMowafRVSimTqQI4RXldY4VjrIJy9q0xXXeXcRnh8I5lK18tkKn3mF4Ya
         1Osw==
X-Gm-Message-State: APjAAAXT5vHjXnMWXo/w8DkHQgCoDnyv7c7CdFetrBvUBTfy/+8SZr2Z
	FfO5B3p2gEQGJiMryWNXZile9a10rkmXMQ+XfJSW7knhUl69HsKgfXd02rXrODhprEfEz8niNdz
	j6+0qVzj4tigUj8RcabVuXfJgHmxcls2USKvzpe5kJWjJWNl+JsW7GOnN6KmsGX0t4Q==
X-Received: by 2002:a17:902:361:: with SMTP id 88mr8283421pld.78.1554406335111;
        Thu, 04 Apr 2019 12:32:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1bVwio1Fpe2lSb+nQYE39CHsebgtsJqJUtXIyp+IV5hdINLFUzik0Y5KMq2F4liJ6rC90
X-Received: by 2002:a17:902:361:: with SMTP id 88mr8283361pld.78.1554406334379;
        Thu, 04 Apr 2019 12:32:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554406334; cv=none;
        d=google.com; s=arc-20160816;
        b=xbsI2ecUGjB016eF/yPIQqO0kfWvSkAeejN0Puwf8xIVq7rKHNLh6WBLNz7bFcrAGQ
         D7dmfZ8X7BUhGci+twHmcyNxGWkeu557/4ipnnUwujpu/Z4YOvNgNNa8mzcTJdv2HiSZ
         LaNP8r2ks6bM1KrAr012UGharS7ZHstz6jBeVyo6aATqppuxw+wlfOvfrcrXMnVJPBuO
         MtGN87c4LNkwNF5SLQ5AQzWTHceJMTkOxOexkAiuraIG18yy0kqCM0W1iz1KTBpdBvyi
         QXAEsp+uxIoXjW3zCQdxLcv0U14TMvE2rSMwids0oJV8D4TDsk0ySKsA7F3rixHnmKNy
         sxUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dRdt+9F2fFh2MhgOyplKH+n+b53N1s6QD7kx64loto4=;
        b=pPy/WwJt7F9ove6oyDlG3/S9GAPgs5QqMRfkpmwK52oGrzwnf4ob7lT9R1PEET2LK5
         4bx4zGwaqK+1UTiVshJ8eoW3dYOIN6WXozb4kIwscmjPYrgtZlOZXfNYWJFT7Iy3ncko
         DIB3ldOlNmHFiNAIVINx+SYVq11F7Ziqv7aBLKJLAIXCobRu6aeyxzXW1ZdmfA50zavD
         3GKPWALzLGEYjFXWwINpo+oUdr0tRHi0blJ1M7Z+U4lvKWcXmXQkp3X31EK6nUonYGpD
         m51LYxVL/5RStqQGwXuvXd+znEaDIyhTDGDIIa7M6Fi8gA4Ws/Ideqbrg6GTsQhm6kca
         SuUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="I/nIbvmP";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y70si15342157pgd.359.2019.04.04.12.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 12:32:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="I/nIbvmP";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dRdt+9F2fFh2MhgOyplKH+n+b53N1s6QD7kx64loto4=; b=I/nIbvmPJtHr+wQsd1QkHPBpB
	kc5Bg4JxKe9J5KCjzwH6yibPkA+4RP1ZcrR6AZWCTeoRV+JKP2NYqDafAUH5LfxmvzdrENJfWyOO5
	yw3VI7GcU4EpCZdLevkjX8+hUJFACFBL1omI+JouUs+Fc1aB9KbgpAdH5xWgwfCnwodyMeHVHYROd
	W5xUwV/lT4o2io08HRRJBBZGUvqZ73KtTXlr2qFV6nksBg1+vn4+TAkyIrzaS/Xvajc1gJPhQkETn
	89zgzkbaImuJWeuwJMqPHg9EYkFEGbCLjdBJmULGoCfynL1q4E+4D/QYsMc1am9xmcLRf5OVTZIQv
	9XLbRQo8w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hC85s-0006uZ-1H; Thu, 04 Apr 2019 19:32:12 +0000
Date: Thu, 4 Apr 2019 12:32:11 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, Keith Busch <keith.busch@intel.com>,
	vishal.l.verma@intel.com, x86@kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Subject: Re: [RFC PATCH 2/5] lib/memregion: Uplevel the pmem "region" ida to
 a global allocator
Message-ID: <20190404193211.GK22763@bombadil.infradead.org>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440491849.3190322.17551464505265122881.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155440491849.3190322.17551464505265122881.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 12:08:38PM -0700, Dan Williams wrote:
> +++ b/lib/Kconfig
> @@ -318,6 +318,12 @@ config DECOMPRESS_LZ4
>  config GENERIC_ALLOCATOR
>  	bool
>  
> +#
> +# Generic IDA for memory regions
> +#

Leaky abstraction -- nobody needs know that it's implemented as an IDA.
Suggest:

# Memory region ID allocation

...

> +++ b/lib/memregion.c
> @@ -0,0 +1,22 @@
> +#include <linux/idr.h>
> +#include <linux/module.h>
> +
> +static DEFINE_IDA(region_ida);
> +
> +int memregion_alloc(void)
> +{
> +	return ida_simple_get(&region_ida, 0, 0, GFP_KERNEL);
> +}
> +EXPORT_SYMBOL(memregion_alloc);
> +
> +void memregion_free(int id)
> +{
> +	ida_simple_remove(&region_ida, id);
> +}
> +EXPORT_SYMBOL(memregion_free);
> +
> +static void __exit memregion_exit(void)
> +{
> +	ida_destroy(&region_ida);
> +}
> +module_exit(memregion_exit);

 - Should these be EXPORT_SYMBOL_GPL?
 - Can we use the new interface, ida_alloc() and ida_free()?
 - Do we really want memregion_exit() to happen while there are still IDs
   allocated in the IDA?  I think this might well be better as:

	BUG_ON(!ida_empty(&region_ida));

Also, do we really want to call the structure the region_ida?  Why not
region_ids?

