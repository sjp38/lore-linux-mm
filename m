Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46D24C32751
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A9242070D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:01:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ram+yxpj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A9242070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DF786B0003; Tue,  6 Aug 2019 19:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78FCD6B0006; Tue,  6 Aug 2019 19:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67F226B0007; Tue,  6 Aug 2019 19:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3187B6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:01:06 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 65so49172802plf.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:01:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yZMh8eE5hwsgkjoquKpyQHHGT99VEKTX8kqklOZGeKU=;
        b=AWeDucCQsh9cjzs+VxurfXwyRD400ES1o3EDHl9B4RBnjUXSJIxVb4y+yhDstDigDt
         bzR9zdDMXWWzz9CjdJnkhNdN4TzJ1ZJmRmC2pDNnXxzyS7DOgewMlYlVGUH/2j/nQr/U
         Xk0oLliMJ0j3BsqAx4HHahr48c0fuKVY8A5eG+BLj8VbIq1asGkn9/YYyrE96YFyhTdZ
         iBWHXrh/WjMBiQ1aFWDdBF8MaYHOrQ+vRlZVtveGdhAEnsnTic7pTdNy+bXFg7I2/vvT
         LrNCwpIXa0+RBsrGGsHLdlj/XxJ+JosNtV1QtG9ttgjoLtH/uf1jYm3O/7YbckkU4xF5
         6Lvw==
X-Gm-Message-State: APjAAAWnHYXRLs2kTZVpvKtA6xQFX8i63eQ0Bo889PDBpT0auGpI4lA7
	brOGD+tvY6h/trT71lFNaGJTnDzRNCxeZnJUFPbApSMIl5L7VpKg+Icd9+7CtlMRKxOKN6rqx9M
	4FU5+rH3y8WDIik4HO/nsmSMpSU9pP3tighZBgXCPOxQG46Y2Y0WlZqo6L754sjjImQ==
X-Received: by 2002:a65:6081:: with SMTP id t1mr5150596pgu.9.1565132465648;
        Tue, 06 Aug 2019 16:01:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHogCOUwMfXkTiP7j0mVDb4xcL9DaA3fkbKwHZTvll7dzGgAYmSjaTmIYteVtbcYP3e2LW
X-Received: by 2002:a65:6081:: with SMTP id t1mr5150510pgu.9.1565132464676;
        Tue, 06 Aug 2019 16:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565132464; cv=none;
        d=google.com; s=arc-20160816;
        b=d+TnFWv4PLZnOAJ1GtQFOdTjYU30LJJpux+Vwpu6nsMctZcQ7fdgPg1csIVkdOHwJB
         4mcsdB1zFiDaqltiop/JXHwT93Wxt33AFerVSxEwjruLFXVt0bxd3s+sW6JTgBBImnPk
         5I/kL4F1jcFNcj3SKbU79g2M62tBBlZXMULBLrQPVfcdE6LdSXGPkmu+wk8u/wWgdcFf
         loso/i9R9TsOPwDHWQZ/+lk1F3F+7X3sP0k5ejFJEQ8bqPku0S0cGzfWJ8ieXKYY//Cp
         OZ7Nzk+WxB7m+0pR2RKe1m1qsfYkmrWAGZ+ZOYJ47UC8eoY9q2mWHpmR/OM+mossJ0cV
         +KWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yZMh8eE5hwsgkjoquKpyQHHGT99VEKTX8kqklOZGeKU=;
        b=mWIAdONhMLxlx719ceHdFt9OdgnbWHaXnfX0gz5cCBpZ984DAeu7/CdXsOqZhX6Hx5
         AvV2tGZEgRkhxcpSx5z0IZnsxbr6Qxh2LIAqgCQl9hekeWrvEYPGr+zNj2p85e5qyXeX
         U044GE2paZ+mGXi1+koUsPY1zmzKSJtv7X3vhaHtuAGawPA5WM7Ejo98C4y2OuDi5iVD
         oxmJMlxnVNMiKOkVvFCXA45snpXtfb2uLsEIlXM9EzBrm0iWPcLpVs3xJClYdMe2+kC0
         7iYcKGRLRshM12CghaxBC3h70/+gXUiNaZ9UycOzCaDyYxZWKvXfuBpnK5bNIZ8dgP23
         np6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ram+yxpj;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x20si8927727plm.61.2019.08.06.16.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 16:01:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ram+yxpj;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8C7A32070D;
	Tue,  6 Aug 2019 23:01:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565132464;
	bh=vGl/qyUj+m3xdNJaJ9fF/HjSzIEZvTJK5xJjIUiHOxQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=ram+yxpjoZZlMPdi2p/p8wC9xbLXU244ul4IK2w7JME7Dob0R4Qy/D1hsmAvZ0GDM
	 lPuIhCuLFw5/g2cagStWN5Eua65k6HVxgrIAfPon7hrUHTVSJGBaJH22M3WDg17C6L
	 TdVf/pEW1LNxxYciU9FWLJmB9xyejRP00N6oKK4k=
Date: Tue, 6 Aug 2019 16:01:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
 vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com, guro@fb.com
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-Id: <20190806160102.11366694af6b56d9c4ca6ea3@linux-foundation.org>
In-Reply-To: <20190803140155.181190-3-tj@kernel.org>
References: <20190803140155.181190-1-tj@kernel.org>
	<20190803140155.181190-3-tj@kernel.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat,  3 Aug 2019 07:01:53 -0700 Tejun Heo <tj@kernel.org> wrote:

> There currently is no way to universally identify and lookup a bdi
> without holding a reference and pointer to it.  This patch adds an
> non-recycling bdi->id and implements bdi_get_by_id() which looks up
> bdis by their ids.  This will be used by memcg foreign inode flushing.

Why is the id non-recycling?  Presumably to address some
lifetime/lookup issues, but what are they?

Why was the IDR code not used?

> I left bdi_list alone for simplicity and because while rb_tree does
> support rcu assignment it doesn't seem to guarantee lossless walk when
> walk is racing aginst tree rebalance operations.
> 
> ...
>
> +/**
> + * bdi_get_by_id - lookup and get bdi from its id
> + * @id: bdi id to lookup
> + *
> + * Find bdi matching @id and get it.  Returns NULL if the matching bdi
> + * doesn't exist or is already unregistered.
> + */
> +struct backing_dev_info *bdi_get_by_id(u64 id)
> +{
> +	struct backing_dev_info *bdi = NULL;
> +	struct rb_node **p;
> +
> +	spin_lock_irq(&bdi_lock);

Why irq-safe?  Everywhere else uses spin_lock_bh(&bdi_lock).

> +	p = bdi_lookup_rb_node(id, NULL);
> +	if (*p) {
> +		bdi = rb_entry(*p, struct backing_dev_info, rb_node);
> +		bdi_get(bdi);
> +	}
> +	spin_unlock_irq(&bdi_lock);
> +
> +	return bdi;
> +}
> +
>
> ...
>

