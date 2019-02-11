Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A192DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AA8A2184A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:16:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AA8A2184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF0048E0151; Mon, 11 Feb 2019 15:16:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9F4E8E0134; Mon, 11 Feb 2019 15:16:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D90E38E0151; Mon, 11 Feb 2019 15:16:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94BDD8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:16:27 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o62so110438pga.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:16:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tfFi7wDcaR1MxxYBxMQyksHkX1H1zCyW+07mUExMn1M=;
        b=egvwiMi3ytyUEnfM5aJDoaXJ1EYsTAF++eQh5qqOcxHmQTWji2kLtUFDgU02Qy75yb
         Pw8h3GQBI4FFDiF7W7nKmvysBIB0xBRLbkGOD1OfQDDJEnKuBi9BFELxVTiQgDv5gQ6+
         zT4jkgC6GJYnDS6eVLB2imwJCNzppSuy1MJss4Ao/XGX1M0BRBn2wDQk43/CHGnara8q
         /A9JPioEXAY3cWf4k4zGvhYa5Z8VEDuiljH84LcD8I1gmWwHs6P0uDwxEZrfj3LZqdZG
         GEON3tngfh9E8oCi3fP60S7ff58z89qzN2UFZewJflpUUUnukLT7cAUIjbqOvaO/z6JZ
         8qUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaP4Zcxgl3tdcYywlXVhrJL/KY3FqfoOku+RsGzx09TXcHYsVbm
	P+H/FeWf6kaFb6q2auw1ArLVoshe5E8lg4VrQrCbY07+HokfYtpO+wim/KQOrjPxN9EpXsNJQ2V
	Jo60f9dEXPwu2gPTI2dZsu5A6QzNmbizB+4Wi+w//xK8YXeC3KnIGkTke6y5lj/jsYA==
X-Received: by 2002:a63:20e:: with SMTP id 14mr20059730pgc.161.1549916187283;
        Mon, 11 Feb 2019 12:16:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZaBYSydZ2GhjY+674bgOKZ79Fa7dY+iipt5JhDRjSCBg6/y6g14CtuEufnr3lw4gV1SDW6
X-Received: by 2002:a63:20e:: with SMTP id 14mr20059666pgc.161.1549916186432;
        Mon, 11 Feb 2019 12:16:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549916186; cv=none;
        d=google.com; s=arc-20160816;
        b=xNGQsMXnm3oO6NditJwWKBSDtipUuXBH5qPDT2JNJfFNf5rOrpJxc/tfs7wUfLyQb6
         0bsbByltNrr0JkM9uEQmgiAmDh/lu2s0R6lXaYM//NXe/7BkVd/pSTg6B4cQmg3/bhQ/
         6i8eICs8NLDpUlnt+XTM9vCDA2SsVcz/Qw5LwG05J3+fAGlzHCOLpFid+3WN9zsxbk5R
         9u8ShXcM9UoJX9YFhkkkBuuk6W0XuFk+VGt1tMHwKKZDWDBhtKY5WebjvFgPmyylX1v3
         rIZByALS8XaFfnRyL4RRzPpf66J1ANNJZlq8L6bYbXgusOCppLpQYuY7aWvKHSqeYokn
         zEVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=tfFi7wDcaR1MxxYBxMQyksHkX1H1zCyW+07mUExMn1M=;
        b=FOdK+H3kSrW1E+8aHko40ZEhwH3lOnLtEulj15SyQ+55r0mDpxHfodnQbrBwVhJ+ji
         +zhCzHkV1+v2G0xgOvsp+RVpqAvl//KgOUhK7w8GWYdGIaWKrKtI2Pvtup3HwraEIyLx
         a5HKaqeTBul7GF+YSQL+pftAfTNDItV6tZ3CEwCcAMJWYocmGiGSUV0lgcLq5hXiH1mk
         eNjEMtrOb8OQpZobummTCXuPmZbmV1pDpetQs7u7EFamFwoxgZAzTqVTKM/QgDUStnsj
         5dkC+5PprqU+eHwfAOi7QEV79dE/qwILQCTAcxlEXp6cjF1Mx6HrN44PTi8pzntD8/dI
         g6SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d10si11218642pgf.136.2019.02.11.12.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:16:26 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 989A2D810;
	Mon, 11 Feb 2019 20:16:25 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:16:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, Toke =?ISO-8859-1?Q?H=F8il?=
 =?ISO-8859-1?Q?and-J=F8rgensen?= <toke@toke.dk>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, willy@infradead.org, Saeed Mahameed
 <saeedm@mellanox.com>, mgorman@techsingularity.net, "David S. Miller"
 <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [net-next PATCH 1/2] mm: add dma_addr_t to struct page
Message-Id: <20190211121624.30c601d0fa4c0f972eeaf1c6@linux-foundation.org>
In-Reply-To: <154990120685.24530.15350136329514629029.stgit@firesoul>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
	<154990120685.24530.15350136329514629029.stgit@firesoul>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 17:06:46 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> The page_pool API is using page->private to store DMA addresses.
> As pointed out by David Miller we can't use that on 32-bit architectures
> with 64-bit DMA
> 
> This patch adds a new dma_addr_t struct to allow storing DMA addresses
> 
> ..
>
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -95,6 +95,14 @@ struct page {
>  			 */
>  			unsigned long private;
>  		};
> +		struct {	/* page_pool used by netstack */
> +			/**
> +			 * @dma_addr: Page_pool need to store DMA-addr, and
> +			 * cannot use @private, as DMA-mappings can be 64-bit
> +			 * even on 32-bit Architectures.
> +			 */

This comment is a bit awkward.  The discussion about why it doesn't use
->private is uninteresting going forward and is more material for a
changelog.

How about

			/**
			 * @dma_addr: page_pool requires a 64-bit value even on
			 * 32-bit architectures.
			 */

Otherwise,

Acked-by: Andrew Morton <akpm@linux-foundation.org>

