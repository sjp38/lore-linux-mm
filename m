Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB9FCC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:23:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B40220657
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:23:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="F6Qxfkwn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B40220657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF61B6B026F; Mon, 20 May 2019 10:23:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA72C6B0270; Mon, 20 May 2019 10:23:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D95B96B0271; Mon, 20 May 2019 10:23:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A39E76B026F
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:23:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h7so9991500pfq.22
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:23:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OatVHIrCWYguW9Na7RTRuHTBGkcI0B4NqgZ1cLxhQgQ=;
        b=HPrf9k0YIb1Gb/LoAWxxDs9KaOfnSbCrcZvUJ1/cU2kNKSsSfdiQAznedDD/ueUVfF
         ASGZfwZgx6sRQJxOLpUw5DY8s9iwlCs6jqdh8JuJhrRazyzpHXubBh/PmPHXQfkJg+xb
         vUOss8vaBLcIith6lTcPAoholfLEBhO0meME8Ipoczbjh1vZEDXgPMSjwvw7XcUNUJe+
         tOFhsUPuzdxJv1tEAkyOin0c12TnM0G+0ySYmOnoZNWeM4MR3PHVea1I5flZbiIdcxkk
         B2ry85AXpLEBtIOzm+GxJJZiEK2Hq+EHvgspXmdhpnPpx2/99TMBzXY2PFkEX9S0cShM
         9EcA==
X-Gm-Message-State: APjAAAXRPxBF8gP+7d/dSxaGEqqiWL6D07CPoH9zWBkwVUiL5bx/eGhE
	ewm1V5H2camYeJmooAPrsn33BjGTDqPn4ZTEOFAJpMHzcR9kXDE7qRmawB8a0MXjP4MwCtd0sYj
	IGc56vfjTUCCpUvM+7V94Gy5ZsP2AjhpIQ59sTBw91aGTBT1AWi6GK6Wvdlq+TJe19g==
X-Received: by 2002:a17:902:ca4:: with SMTP id 33mr38899871plt.107.1558362215176;
        Mon, 20 May 2019 07:23:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0TpV+NF/e574pQYOdhO6Vy0H1UwwoblghXUaTkLBZhiH+8mJL4ojxXebe89gcLlJ17tgO
X-Received: by 2002:a17:902:ca4:: with SMTP id 33mr38899804plt.107.1558362214448;
        Mon, 20 May 2019 07:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558362214; cv=none;
        d=google.com; s=arc-20160816;
        b=IwWRyB9GmLmNoqIopLNYj9HuRb4ej1+pLPwSAuplXorJgs5pj9foPInaGvLrgKWx8I
         p86pAFvDjLqGA9QH6XJwt9ajrq2yFY1DN3OslOsmqh2Mgv2Qt3ro6ECizL5F65/CH6RO
         OmnZNT9X/gumsE4FbTMcnobFBJkKcNsAuHgKN42T1b9h07Jg9L8k0PvlzjoIVFbY3Eah
         cXj9orlrhY7eTfI4wuhlOzRmJPHhbXidQ1uqakErgJlwfbvwYf1w/CEyxjFZsrJEvSAR
         UKCvMsP0oOaqBOeoYmrrMj2gQU+7tZ5AzFfOII3yk32n5EBtPMDubcpQjmoOebSkGz+l
         L2OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OatVHIrCWYguW9Na7RTRuHTBGkcI0B4NqgZ1cLxhQgQ=;
        b=J4kG+H4DWSvB18OLXahuewvcBaBTNwHZ7Sh8WZI1Y7LxB6NMym7uio8zUqKCdQsTDq
         jWKJozeJabVTRW10JOdTczDlknK0KguRB8x9LEf7z4thWkAGIjdYnTNaKT8Nt6mtPXqX
         8K+ubIxGby6wJUkA9WKkLIiBmOsJzJldzfsVECh2cwGaOMAbTXjrKT6CTB80O9LyxPiB
         NBcZ0vQ7vX2KVCshaI7ZUGGwJoo4kr1uvcrQ4thNRiVTkcf96UvXtZmVBuZRhC7Tl3aI
         MHcdnSJmrPPn18qyhERgD3Zymv6KdSPIXdKrFMu5f70MLidW1iaTCSWldJfq4bRpiZda
         lJNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F6Qxfkwn;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n81si19413731pfb.258.2019.05.20.07.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 07:23:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F6Qxfkwn;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=OatVHIrCWYguW9Na7RTRuHTBGkcI0B4NqgZ1cLxhQgQ=; b=F6QxfkwnuYixy1VbMF0FyONlO
	dsWCZHGjFMaTg+CXsiL17P09p9tVTwmdejillTJOVKTk/anWvWL7/2Hjnuh5LWjmsNBcyVvck9ejw
	qRag5Wnz4m1LXhBpxrUmjVbrTKqVDVxM3SLJ5hRyo/66WXxDBVFYyNwcKp+0msVjFMiON4shXUf5H
	vbUY6T4yOTY7RrgQqYAH4p/LVBT6jkqdtXedMJk6ExQoBvbX8XFofYNevHhct2O6nnOdHeb742/3u
	cTM60s4nWRGiMl3Wt1xdFEVJ5qZgbUd+XZapkxqz3GuRKvPS5fpJirF6QQ06yJccuyRVkv3a1PPwd
	Mke8wj0lw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSjCN-0003ZB-Ee; Mon, 20 May 2019 14:23:31 +0000
Date: Mon, 20 May 2019 07:23:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver Neukum <oneukum@suse.com>,
	Jaewon Kim <jaewon31.kim@gmail.com>, linux-mm@kvack.org,
	gregkh@linuxfoundation.org, Jaewon Kim <jaewon31.kim@samsung.com>,
	m.szyprowski@samsung.com, ytk.lee@samsung.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
Message-ID: <20190520142331.GA12108@infradead.org>
References: <20190520101206.GA9291@infradead.org>
 <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 10:16:57AM -0400, Alan Stern wrote:
> What if the allocation requires the kernel to swap some old pages out 
> to the backing store, but the backing store is on the device that the 
> driver is managing?  The swap can't take place until the current I/O 
> operation is complete (assuming the driver can handle only one I/O 
> operation at a time), and the current operation can't complete until 
> the old pages are swapped out.  Result: deadlock.
> 
> Isn't that the whole reason for using GFP_NOIO in the first place?

It is, or rather was.  As it has been incredibly painful to wire
up the gfp_t argument through some callstacks, most notably the
vmalloc allocator which is used by a lot of the DMA allocators on
non-coherent platforms, we now have the memalloc_noio_save and
memalloc_nofs_save functions that mark a thread as not beeing to
go into I/O / FS reclaim.  So even if you use GFP_KERNEL you will
not dip into reclaim with those flags set on the thread.

