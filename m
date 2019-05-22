Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6352AC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23B9120821
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:03:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UgB1AQS4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23B9120821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7646B0003; Wed, 22 May 2019 16:03:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7AD6B0006; Wed, 22 May 2019 16:03:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BCAF6B0007; Wed, 22 May 2019 16:03:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 652D86B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 16:03:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so2430400pff.11
        for <linux-mm@kvack.org>; Wed, 22 May 2019 13:03:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ViBWmnJ1WWRjeadhKTVeKeDH/rKW/qS58ZTaSpuylpA=;
        b=dbSN0k1gEhnATwkBGFJ2A4Gs4qvECS4ss1iWgBJcVIFMNiASRO3/n+M9wWSWCojFAE
         EAccvDOt+/tQS6Yf62mUUdO7nQGkEoKkwxUp55FkA70eE5o+fL8TotQrTdqwe1oS49yi
         w2m2bRuEWR71qUT9bDY7F3nQXLBhUFoH9Ii55K63WcQUabYbZ/xipbrj4udJYpYHRJ3X
         8E+QgktIcS8FrcSreT3SxNMhKEQrYXib6X//YbPadzfm2OfxyIW3xGXljtEriBdZgse0
         9eNnuCsmZbMZ+DL0OB0hEjpHXSjgVyYp0sbjOMxzL+4sMhhHqnBrHPz6T1o8S953t2zV
         nczA==
X-Gm-Message-State: APjAAAXFP99BE8t1Jy7wqXEHPYHYFLJR0b45FJuI9zp345dY7xO86BNc
	bbp9ww9DtbKsjzYVHa1JjRyq7L+SYm2ZW1iGOs/HoR7R4KStIUPGtcAOxugZMQ0Fw85FRgaB++c
	NeTmSCxSL+U5ZbB7j1M5cECgLqLEJm4ZiloOFNm8ISFrnL9y3DIEFZkj3+9q/r2H11Q==
X-Received: by 2002:aa7:98c6:: with SMTP id e6mr96507658pfm.191.1558555401924;
        Wed, 22 May 2019 13:03:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBc7utzbO/1cnuB6aWwOJrR0LZRReLNwa3eL8REH4CAsej487nELXuaXiRhjPbqzZvV8zk
X-Received: by 2002:aa7:98c6:: with SMTP id e6mr96507556pfm.191.1558555400869;
        Wed, 22 May 2019 13:03:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558555400; cv=none;
        d=google.com; s=arc-20160816;
        b=ZweDTWngJbeDcDh56qtvHUOIzr9tdhM//YJIJPJXFQasx1Xe5CaGTekmonkVijFJP0
         2nvb+LSmC1x+NGMbDHHR+pGpDHMo8eLYUpn5k3vR2WUJaX5aNoMjo6jFoi6ir6DPkky/
         vlIJUCztyrs04BilFp1+eYMQdBHvY8W8odYEZHDB/5b+an6wbTZQWRN3F2MhV4P/8bwa
         PWN9R9sx15J94EeS5EoVR2Z9l6CFQKp5nIahxKYfseM7km6VN0ph+hAblEIGya/8BqQV
         usG2NiWNIEDVcFpCLVQ6UnCTOdposP5IVtPKT3VSVKNhxBfsX/UpECUL6WqWIdROPwzZ
         5weA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ViBWmnJ1WWRjeadhKTVeKeDH/rKW/qS58ZTaSpuylpA=;
        b=eRgPMU47Bq/4XchAJ1alh4MY40suyHDJlMFrPaoR3xYoYkgDi/uXCn0iy7Q3ClVxvd
         JxeynmR2GtrGt0kxT1Po8NGnuwBNrVXrOFy1qR6jBGQPkMcLybk1iLmj1nd8JLkClHEa
         4XuvnYrLPCf5iudI9BTgDFXXCLzQV677pfaJHHTGW3zJ+Nqs7XCydyp/0qtJ/YJX1RlI
         ohLJww3LEhNhlDj7T4a7kJbN27gFxnxFwjkIUYIDOBoFcuLxnLILu0poFsno5qH6GAXE
         GfNEES/V+6lE+sY5WuAV0/Bsp0S/cSaxHLz3MOwZBD7DZ2ayjWYfMXmpuDpMUexYrJ69
         xT0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UgB1AQS4;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q19si27710120pgj.42.2019.05.22.13.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 13:03:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UgB1AQS4;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 50B7D21019;
	Wed, 22 May 2019 20:03:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558555400;
	bh=k7OHZtB7uPGFrxLGQe4UNcjIGj64t1q7pu44dSe2Cyw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=UgB1AQS4VimS8HjoFDHM9P9wg8hUv9+hL3dU6a/IOC2C5rf2F5QJeknzjX1MMcx+O
	 zy5C8PlqiqGx2uRa9D6wVdzLPrifZd3GiOtzdkobg3piCl2OjFEsPbpQXty60iwe6d
	 bp0Z6gFrH0dwHH6wIEnMZHaqGN2rZQ443G0Vo6uc=
Date: Wed, 22 May 2019 13:03:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Introduce page_size()
Message-Id: <20190522130318.4ad4dda1169e652528ecd7af@linux-foundation.org>
In-Reply-To: <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
References: <20190510181242.24580-1-willy@infradead.org>
	<eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 May 2019 15:43:08 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> > +/*
> > + * Returns the number of bytes in this potentially compound page.
> > + * Must be called with the head page, not a tail page.
> > + */
> > +static inline unsigned long page_size(struct page *page)
> > +{
> 
> Maybe we should underline commented head page limitation with VM_BUG_ON()?

VM_WARN_ONCE() if poss, please.

The code bloatage from that is likely to be distressing.  Perhaps
adding an out-of-line compound_order_head_only() for this reason would
help.  In which case, just uninline the whole thing...

> +	return (unsigned long)PAGE_SIZE << compound_order(page);
> + }

Also, I suspect the cast here is unneeded.  Architectures used to
differe in the type of PAGE_SIZE but please tell me that's been fixed
for a lomng time...

