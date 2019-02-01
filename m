Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E929C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:43:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D01662184A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:43:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Z5RhYiau"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D01662184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 773308E0002; Thu, 31 Jan 2019 21:43:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 721498E0001; Thu, 31 Jan 2019 21:43:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 636BD8E0002; Thu, 31 Jan 2019 21:43:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 261648E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:43:17 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t2so4269814pfj.15
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 18:43:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Q3gZsciv+RQVX9T/SHGocIS11HiPzVpAVPCjgkGweCI=;
        b=lMfK9lC2PvkGCnMffuZMIcTUog02MWAJAkGsoGJK9sCNphU4U0M/AKb4in39Wvy1jH
         TUz2cJWJevrUn6XM1xhMElYfHKwveB5SDiHw2LgfkeDeeK6uqNZ+2T6EsKrmR4wGJRSF
         +GTq1VsjjXA0kn4ahdBvNi1mxezFeY4OLSI6JxGfpCDROJXLgoICDAixqaSqnrsseBRU
         36uSYdhABAaQFkcZfr+5AOtaxallyskrfwZs2koPeIdrBhQjzTc1kj0EE/R207+vvYwe
         np8vFGU0oy7ZfVCOHXu/KC0XxLfup8hxlbD7CZ7QIc1MVOK1YXTNUH2lLJ1sEaJ6FYC5
         WiaA==
X-Gm-Message-State: AJcUukfyr9pxUieDve5hxNyx1Zr7ol1Fa9wha09m5z4NiZOW1J43Cjzt
	w4XY/JEw8Yof2Fp6df9f6yMGbkodD/px2R2ldY1hBJBKQ6g1Lg/1QzMjORWVM/dzSmZ0ObHYazP
	nMKtfpDKuyEDw/b0ZIibFI6+/3q26B6sRKJqIMX/k/gPir2xFlMY85b0M+uZ8X7IKLQ==
X-Received: by 2002:a62:6503:: with SMTP id z3mr36344423pfb.169.1548988996686;
        Thu, 31 Jan 2019 18:43:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7XUpAmgaFJmlvQIdr6FD4IePQlC3nyglXjK+S9HuOSHw/YvL2HpDtBNxV2PVAoUMXe6vZl
X-Received: by 2002:a62:6503:: with SMTP id z3mr36344391pfb.169.1548988996039;
        Thu, 31 Jan 2019 18:43:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548988996; cv=none;
        d=google.com; s=arc-20160816;
        b=oifObultpyzP7y6OZdX1cZmT6OgVoBoTw/gR1+4HI2ds2qmnCUYNKFuIkov8/tTUF0
         x/Q+oJupjkgWUDuYYg1CtdyFuRZ49NgFoegdMuoRf0th4kTqp1Hg6S2gJOl+VhNeTOr2
         +zJ2f933NuGopkgAEEvehWVIdZ37fvrbJMl/HTrbejYliGzOKp9UA33ocYO+xYWc6leu
         MG0c+gQH58ubtdrKCWA+OuNXxxtsUf2OtLNPUyWZrSapxfWE+AlwW87ZnI7TlXagO/vi
         KWAXevOWULkrQzoqjJiDUJj3oiYI9AKKt9rkc0x51L/AxU/OpTNWm8fVqpLIih07IEDc
         CWcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Q3gZsciv+RQVX9T/SHGocIS11HiPzVpAVPCjgkGweCI=;
        b=hCXSONBjPmbimnavVWnO7Nk+Xcu4UWNAFn5DuTF8oNkLUVOp5UEsCEqNcIbyepaZxt
         pPnutHCMdX9zgGSlPlL+jdZWJXvbdLq2lcGKU9JDPqayletRTSwZ44ew74ZL9El00DvF
         JU9+Y8TnJxgpxC+UWuUW0pSj3aA2eNscDClSGBO+Jjo/K344M+PUt9oDp9fhZPoG7C9H
         eOeNrTsFEw74jbQOMOPIFLNJ8SvWSjYae8TDjk0gnOushWgpcOzPCWXY4p/ot4/zQjEb
         ClV9o1GnaDIZzlsQdd67vVaTOa81D//QGhM1rzy7B6hQi5qpMRJpSjueRF0tchAl521t
         9INQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Z5RhYiau;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u9si6923080plk.61.2019.01.31.18.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 18:43:16 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Z5RhYiau;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Q3gZsciv+RQVX9T/SHGocIS11HiPzVpAVPCjgkGweCI=; b=Z5RhYiaucaPZ6DFGE5zc0+p9a
	21KStfuDNUbEi/1XybZoaFCWXHEGsKNGFX/tBNtOwoTaGoEFT4gZjOUfTN9KPpOiV0cmaQIu0g4lj
	kq9PMnVhc+ukuv9XIlnVpZM4tEnjvaCWWwrxMFAA+STVCdDLrHQJsrOt+W6OrpYwCAM1/QO/amwAb
	2iP0gqMtMBYoRlRwr2kUBi6jAqQoHZ08AMulZszn5o1BxldtTQ6HtEGWWRLV6U+3/490n/C0GZMIu
	XbbFEibaQ+koimyuq/ABRazvuscyBtITQrK7XUJSJzfLDVkTp9bTVxn9AIZTh78rf4moT+Q1X70bo
	Lf3CZqpEg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gpOnO-0000L9-FL; Fri, 01 Feb 2019 02:43:10 +0000
Date: Thu, 31 Jan 2019 18:43:10 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190201024310.GC26359@bombadil.infradead.org>
References: <20190201004242.7659-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201004242.7659-1-tobin@kernel.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> Currently when displaying /proc/slabinfo if any cache names are too long
> then the output columns are not aligned.  We could do something fancy to
> get the maximum length of any cache name in the system or we could just
> increase the hardcoded width.  Currently it is 17 characters.  Monitors
> are wide these days so lets just increase it to 30 characters.

I had a proposal some time ago to turn the slab name from being kmalloced
to being an inline 16 bytes (with some fun hacks for cgroups).  I think
that's a better approach than permitting such long names.  For example,
ext4_allocation_context could be shortened to ext4_alloc_ctx without
losing any expressivity.

Let me know if you can't find that and I'll try to dig it up.

