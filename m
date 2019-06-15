Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 349EBC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7AB921848
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:16:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qJnhMHAZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7AB921848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B32086B0006; Sat, 15 Jun 2019 10:16:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE2AF8E0002; Sat, 15 Jun 2019 10:16:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AC5D8E0001; Sat, 15 Jun 2019 10:16:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62A086B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:16:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so3778212pfc.2
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:16:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gD6VIqBkLgYyVrhSIGdqF3irdAhekwacGCLxmHhYe7A=;
        b=rNjeLIAE/f38YvOEB7rBhLiETy5BCaA1+2Yai1XrGvMBKN89chuBEG9Dvl7VJjXWnE
         UfWz/v7OgLkjTTtdCCQoyPER9sIeRkmeiCWkJAuExZvajEsbvYgcMOS5n/4W4hySeT/s
         bmQmyfkKHPzajdrpxFK66fzV2EVauoyWOHyiZy1JoIH6J2zKPYZqidsXFjncQmOBAM9s
         FriPkRJp7TPGIRTVaNRFVcznOLLcp/sUDZQCihZ7n3zUmPepxTvnQcbUENE8hETwlD4R
         zuY8awT2Jc1lWqwkj30M6rwfNy5wLfbQuys/F4xU5aZrsrEDub3wsYiFtzo8tVQabZEP
         TbOg==
X-Gm-Message-State: APjAAAWDj2jyKgtbEl0r0BnoNssGyFI6RGf8J3+zuY+6UP7LPMbC5BZw
	Ez3yuFgBIh1JvRsUX9F4ydFnLXud4M0TSZNgp97ZXhnBfVdoqq0e4nXyoyrOkfFuNeTFoobSlSz
	zazYqxN/9ea/9VS5pThAeDtG+PNtEu6r0ohHe+tOXHk84IH5r4wSp/yFDG6CYV5QX6Q==
X-Received: by 2002:a62:7a8a:: with SMTP id v132mr81528702pfc.103.1560608175087;
        Sat, 15 Jun 2019 07:16:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzX9UUNMbjR0yFNxqrinn61sSfVycrdmFbWrYk9ewq75uF9gHTrPj6su5iracG0O5sSJbjW
X-Received: by 2002:a62:7a8a:: with SMTP id v132mr81528655pfc.103.1560608174450;
        Sat, 15 Jun 2019 07:16:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608174; cv=none;
        d=google.com; s=arc-20160816;
        b=EfPaHaBHfWzKIv6foBvaQXU79PywGRLZBVVPxIAFjulTMK68W14uiDf8dmeOFF36Y0
         AeuzQCojM7iWw4fTV52F4J6gcglzU4SwLP9vmCCM2e0XEDGXeRpjWfgE484YOH6+Pauj
         wzo4Y1Y/6iq1/fBUsPzRW4STIXY78PJ8ID/Je0EhNOAg/jTSP6USsfHII5/I1OREDf0u
         052h3SyZ6VY6b0gWF2RBeEWO71UeA2Z1LE7XtNG27UJ2r8BrEHSjBpRtnWSN+7Z+ksrp
         hRVkzKrHWKuoDGfA7PXOQmRAeFCLur4QNpRVR4hrf1g4dUfT8NeRDRE3tkIyg/geWvwX
         YgDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gD6VIqBkLgYyVrhSIGdqF3irdAhekwacGCLxmHhYe7A=;
        b=epmL2QH+69GN1TxnaYyKL2Yk7bEmhdBHjzal6p+MuPd2EGRWxhwalyyCjz4qsVyMdA
         eDJLrkC09S9mI3a5Y94J+mX5psBJv0k9Y32Uw587t/hScsZJlijr7zWehuPkGGkeEdNm
         x+pkKa4ELT/UlB7h7n26LSI1ONE4MJWsnwM49+3JXBfcy6kqjm3HmfOLoL6PETUaFMNI
         yVF66hxhS5PWjFlSmTmroyRKs2Qyv05azvvG2qlxMURmrYa7JVpI+S4+n9Tkp12wzg/Y
         k20pMkNlAI7U05lyRrOcCzPkRo196ByB5gZEzGy+a5/Z+HyfTiNCJ2f9HjvIhBgL3B6o
         f+sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qJnhMHAZ;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g2si5294138pgs.215.2019.06.15.07.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:16:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qJnhMHAZ;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gD6VIqBkLgYyVrhSIGdqF3irdAhekwacGCLxmHhYe7A=; b=qJnhMHAZBgQNHi8eUuOeP+8LI
	JxIU15mLHHerFUAADAGOP6itU3lIQb2h1qGivB7Ml7JzdNmXu2f5C2gevwIfVeOAmTRUggKSAIJoY
	l9T0oRnfDSCSkHCdqyMj6u3Y5o3reIYdhf8DdeR2dUPCvNrWxOOqHOO5UZMcmDf2QL2I05fSY3NSw
	ij7iywxXUP2MwChDJ/tZqKJ9MiVKfYktf42nkE0PVJzgVi05btfij2DbfWHgKAYVJ/5+fM+TxXQ4t
	DCCAo80gjD34vxw55WwgMV7Hv7Jj4RYXj/nbUtd5kQe/hk1oFC6PFPvPZWUDzWqT8LVwa2b+p6aHs
	AIBLPQzaQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9TY-0004Oe-PU; Sat, 15 Jun 2019 14:16:12 +0000
Date: Sat, 15 Jun 2019 07:16:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 08/12] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190615141612.GH17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-9-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-9-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:44:46PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> No other register/unregister kernel API attempts to provide this kind of
> protection as it is inherently racy, so just drop it.
> 
> Callers should provide their own protection, it appears nouveau already
> does, but just in case drop a debugging POISON.

I don't even think we even need to bother with the POISON, normal list
debugging will already catch a double unregistration anyway.

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>

