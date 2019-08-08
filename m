Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10893C41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C47132173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:37:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LY3zYxhJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C47132173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 660F56B0274; Thu,  8 Aug 2019 11:37:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 611CA6B0276; Thu,  8 Aug 2019 11:37:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 500FE6B0277; Thu,  8 Aug 2019 11:37:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF966B0274
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:37:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so57877373pgk.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:37:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YRzw+ugwPDJo0McwXZm/ccv31s0nPL4olEWIbHVM440=;
        b=sMGfhcAUx0Cr9pdr82NTxvDOGdgl1UPdT8PWLtID7XwG+Uy7j4VtgEwQC7yBkv50H4
         6Bhm72iIAHYYe3G3//YEO8UqCpHMHpoUw0Dg+UNXXbTQwFFwmXrM2ZDLvp+N+ebClZ8R
         dOd66POstyyeJPHdKMVA2ftX8uUtNfY9IP+6iVrZ06f758ivgQ7KlQYYQ1X/3a/pIpdo
         vUcAMv7DsPc97Ije6+hOFq1Rrfx2lAYWbZAf51bEFFDsh15TfmSuvw2ODvnMpf5M4K14
         ps0sPECigTLsyH+6pxOJ0V60IIcI6XGorlplNYx1iHixrC7pbqu8nfo8S9cNASFlpPjV
         Ec4w==
X-Gm-Message-State: APjAAAUPooz7DgM3rMwwG/hX+9S+PFE/qFK687APA3OFUaAi5w7aQvIs
	9n9uSbxno7qiPImXDpSAE6XyPrSgQ7XavhajbXMYLrD3yP2cXdpT0ewaF3FAbwlfMNmd8dyzLp0
	plJsvNQ0ql9YmakV0GlX6mc0O/wncD9f3g5qb//I4nUm6WzZHGPx3oBUSCzJDeazanQ==
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr14064155pln.311.1565278620787;
        Thu, 08 Aug 2019 08:37:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+4ljlZ09HL2pJNpBiwPXWUk2b/7z1QLtiC9IErWQ4ssA0A09JRza5ttjLq8bW5MFORpes
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr14064114pln.311.1565278620195;
        Thu, 08 Aug 2019 08:37:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278620; cv=none;
        d=google.com; s=arc-20160816;
        b=v51d+JzoaBLpRrBsC8fCXtyVyM9s0dt5ppVdNhNI0CX9gD5ChXwcdGLvOqJHqvQHHw
         wBsZBCgqO6WLhc/VQJcmxFue1cB6+xgfHiCLewZZcVDYPIUYqek2RaT+sh5skZ8GXLmb
         cXzVst5M2cfe0iMs1Yb0L0GYbg4sQp1FSQKGD+dzNm+mqugMoPuGCO82e4DLqG6SLWan
         MOwn4V/bJL86TwA3pIvagAycqndkuYx3H7658CTWQ7vMdCUGFdCgYotRADESgVGH9GuL
         H6q60dvz8U3PQ+iztziUA5zulmjgD2Gb7tGBPdO/JKrUtSjE0Kvf/wlty0/SrgaREnmd
         MESA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YRzw+ugwPDJo0McwXZm/ccv31s0nPL4olEWIbHVM440=;
        b=YMftQiAnks9lV99oCsNQwtBRCkGqxHgoPif0leNpcoLZwXElI/iskQEEucB6QP6leO
         0L2DHOelPoDu4X3zKX31FpeVxSfqTcO/U99/JxQazYYwGciOMd4ZXy6BLpWQYLfHNsAF
         RhnqZgEsbpkzBEhDcztHJWgB8ZVgO4bTH0Igr2GuK8UloPjI7ZeqLJAIYkGABNVoCvTr
         hc3qHXJK+I5r0u1Z2gYN0SuM47PmU66wG3RfOhGh/8r3Xbwmm+1r2a1qgbSyHHq5UxnI
         dAu8YilNvGor+A8U86DbU0Jp9hSD44uSHuw/TEFv9+/s4LsFRE3IW/HLiH1RMwcUTlkF
         hXdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LY3zYxhJ;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j12si53274359pfe.188.2019.08.08.08.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:37:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LY3zYxhJ;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YRzw+ugwPDJo0McwXZm/ccv31s0nPL4olEWIbHVM440=; b=LY3zYxhJI3rJ1ATyZso/zZUNt
	RyUhPplysA+Gyg11owELXC2WzPPt+J8obIXyDwvNp17hja/76wjVW3ZjSxwgoVDzps3LEOE2aAjH8
	jribfH31t4bveI+OXr9cdplwyB3mzMXmtn/7PN00gRchxdmJrkOrhZ5b8nEbMjLwbQcd8noGLgY9p
	t0ld9+nvY/MXQ88c0bemuECm5mz+MRX6bGiCQknj8OBiS+FTKCWiB0xHU/pZLPXo1Eci9asvHbGeQ
	90UuFiVkC2R/FqjEX4+bL/oy4AREDBDoShmlBx20Amgj/MN1XCwh9d0tXaX0+9Nrat6NloG5mwdz5
	ndYkuN+DQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkTK-000703-FB; Thu, 08 Aug 2019 15:36:58 +0000
Date: Thu, 8 Aug 2019 08:36:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org, linux-xfs@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190808153658.GA26893@infradead.org>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
 <20190807205615.GI2739@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807205615.GI2739@techsingularity.net>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -			if (sc->may_shrinkslab) {
> -				shrink_slab(sc->gfp_mask, pgdat->node_id,
> -				    memcg, sc->priority);
> -			}
> +			shrink_slab(sc->gfp_mask, pgdat->node_id,
> +			    memcg, sc->priority);

Not the most useful comment, but the indentation for the continuing line
is weird (already in the original code).  This should be something like:

			shrink_slab(sc->gfp_mask, pgdat->node_id, memcg,
					sc->priority);

