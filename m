Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8233F6B0078
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 12:31:45 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x3so10903295wes.5
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 09:31:45 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id q6si13006492wiz.104.2015.01.21.09.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 09:31:43 -0800 (PST)
Date: Wed, 21 Jan 2015 17:31:28 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv2 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150121173128.GV26493@n2100.arm.linux.org.uk>
References: <1421813807-9178-1-git-send-email-sumit.semwal@linaro.org>
 <1421813807-9178-3-git-send-email-sumit.semwal@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421813807-9178-3-git-send-email-sumit.semwal@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, t.stanislaws@samsung.com, linaro-kernel@lists.linaro.org, robdclark@gmail.com, daniel@ffwll.ch, m.szyprowski@samsung.com

On Wed, Jan 21, 2015 at 09:46:47AM +0530, Sumit Semwal wrote:
> +static int calc_constraints(struct device *dev,
> +			    struct dma_buf_constraints *calc_cons)
> +{
> +	struct dma_buf_constraints cons = *calc_cons;
> +
> +	cons.dma_mask &= dma_get_mask(dev);

I don't think this makes much sense when you consider that the DMA
infrastructure supports buses with offsets.  The DMA mask is th
upper limit of the _bus_ specific address, it is not a mask per-se.

What this means is that &= is not the right operation.  Moreover,
simply comparing masks which could be from devices on unrelated
buses doesn't make sense either.

However, that said, I don't have an answer for what you want to
achieve here.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
