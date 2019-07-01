Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A734CC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 23:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CCC12173E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 23:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="tEEn9+dr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CCC12173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECAC26B0003; Mon,  1 Jul 2019 19:51:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7B5F8E0003; Mon,  1 Jul 2019 19:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6AF68E0002; Mon,  1 Jul 2019 19:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id B0B416B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 19:51:54 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id e95so8023712plb.9
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 16:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QitHAFa6H5RAlBAVZiK1b2yS/3+Den09Eo63Nrr/pv4=;
        b=Hk5k4JojQmSsoiHhP0PzLvE4ehfnMV2jGFRCy8LQkVHk+0hFMqvlqyM19zPS3nlAy+
         EpyeUWK0BbuP5TaalSiL7G/lF1CizzdoLoIV95hih177J1qXNUuLvljpYV1J6pRNxYBz
         A+xFDwvBtK/6OyPBMROjoOBZCqhLCHd1qYB/s5yOTExj2IR44zS375O6nYJy1HnPUL3t
         yFgQ+Sivxx74rQ9fKWCYWSqhaKX5e6iPXY1htSXjk6F4UqHtC2FfVscwpQptbXY5u2bq
         TNalNd4hbR/F6xsGIZPkwHjGv3QZnv00XCuOcDXq0eptz6dSgSfhRaNsmRC+L14SYQ1z
         NGsA==
X-Gm-Message-State: APjAAAUoUGycV4ZdEJ26Q3BGfcc+UtT6Urjk8v32D3orX+eM1iJqkqJo
	hx9BdGLRSbOOQm4LklShTdjrkS3GU9SGmllWslGpeoh9rnhFH5Nv2BUFGA2kyQLQ/zaM9NSZnDu
	jPVdhfFjw54Djr2fNxwPi7LPawybZ9n56vcLZhT28H1ELD4Hp68DvyAZjCZuI3Htm9g==
X-Received: by 2002:a63:ea0a:: with SMTP id c10mr28381501pgi.426.1562025114279;
        Mon, 01 Jul 2019 16:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIfxqAfy6OWbz1mv+/4U735pJDfioqWs64jcn0QPNDmMzrr9IA4urvMk6F/stvc9dl4+zm
X-Received: by 2002:a63:ea0a:: with SMTP id c10mr28381421pgi.426.1562025113346;
        Mon, 01 Jul 2019 16:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562025113; cv=none;
        d=google.com; s=arc-20160816;
        b=vR9AHuStjov98j2MjF5/WKAx3LhkKwjM2Y6Stz3Z07SYjjQTqw6g9o/Je3o+Di1oo4
         I3UvFaYkHRs/d5z5EXkKlf0LmodIcd/bv8FdkQzuaqVcRytEpPfxKu5C+eHjw8KXaWOd
         Mfz3aZEY5jzn2aDZB6T/navMVlynqLhwPfr+4mSyOZawXR7L0uytA9vTq0/36PZ2OGW8
         /r+iAOtCVimWT4yN7Byy2tffxhz/fbZTIdo9TU2/I7A9wYRfGfPi2JcaeqzuLPgoyS4r
         cJIIUEHYHkC2SGht+A5oT0sGRDwqXP7SN7Lrg/saw9aSyKPsTSDvaILI2ARiq59HolI7
         H7Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QitHAFa6H5RAlBAVZiK1b2yS/3+Den09Eo63Nrr/pv4=;
        b=zsqS92Xk2B0Sgi+uaBCehyVZm1Jac3++2bb0fOn+VChhoRF8urv33B5y/De2pLBhxC
         bCWjBkFwcmGX3uwl6rtZjsEGPCzYfHd0bK8GMgALd9PKy7khn/tSH4TJ/AxqEPMNC+WS
         pXxyoBjAQK27egN6zaixW0DjT3GLoXvmqI7D7d7CSopYteWN/0HwDPDCfFOuHLHNE7e8
         dLaa8bZAPjjAZVllQCoTiz+3h4V1WL+2I7UQJBsz7oQQlrIdSUc5GP/sA3LKXP7/8Ad5
         ZTdWiB2rcxdIdktixuOVYpnJ/NTLskRxss78bL5zDjXnx+yfoSM0ZQKnhZZGPKL0rPj6
         QvNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tEEn9+dr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g35si768649pje.73.2019.07.01.16.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 16:51:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tEEn9+dr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9CACB21473;
	Mon,  1 Jul 2019 23:51:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562025112;
	bh=m49J8QUAIUGzLQ10Pk7MDlm3F9FEcvjOwjEaylX3Yg0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=tEEn9+drzZeoB0fZ7R/AqFp9Wzc7N8ww7Vx902mD+h3w9UbMjzy9+UZPaIV+7VP8V
	 NDsRCIHliWNtovAnQoKH8EnUvaYKwMZYlGBgh1p6MTymacyx+u8OdvNZ2Wd/9kx4jf
	 Qr+rVz9DGogNzkjQgju1/GWOVyi6riVhx3LtcqkM=
Date: Mon, 1 Jul 2019 16:51:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: dan.j.williams@intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH] mm/nvdimm: Add is_ioremap_addr and use that to check
 ioremap address
Message-Id: <20190701165152.7a55299eb670b0ca326f24dd@linux-foundation.org>
In-Reply-To: <20190701134038.14165-1-aneesh.kumar@linux.ibm.com>
References: <20190701134038.14165-1-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  1 Jul 2019 19:10:38 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> Architectures like powerpc use different address range to map ioremap
> and vmalloc range. The memunmap() check used by the nvdimm layer was
> wrongly using is_vmalloc_addr() to check for ioremap range which fails for
> ppc64. This result in ppc64 not freeing the ioremap mapping. The side effect
> of this is an unbind failure during module unload with papr_scm nvdimm driver

The patch applies to 5.1.  Does it need a Fixes: and a Cc:stable?

