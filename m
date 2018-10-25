Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9B46B0003
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:29:08 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a13-v6so4634462pgw.3
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 22:29:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b32-v6sor5618968pla.12.2018.10.24.22.29.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 22:29:07 -0700 (PDT)
Date: Thu, 25 Oct 2018 14:29:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: check encoded object value overflow
 for PAE
Message-ID: <20181025052901.GA17799@jagdpanzerIV>
References: <20181025012745.20884-1-rafael.tinoco@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025012745.20884-1-rafael.tinoco@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael David Tinoco <rafael.tinoco@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Russell King <linux@armlinux.org.uk>, Mark Brown <broonie@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On (10/24/18 22:27), Rafael David Tinoco wrote:
>  static unsigned long location_to_obj(struct page *page, unsigned int obj_idx)
>  {
> -	unsigned long obj;
> +	unsigned long obj, pfn;
> +
> +	pfn = page_to_pfn(page);
> +
> +	if (unlikely(OBJ_OVERFLOW(pfn)))
> +		BUG();

The trend these days is to have less BUG/BUG_ON-s in the kernel.

	-ss
