Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6884C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 11:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 560EC2075C
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 11:06:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KpKeoXxD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 560EC2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D438A6B0007; Sun, 26 May 2019 07:06:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCD406B0008; Sun, 26 May 2019 07:06:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B94736B000A; Sun, 26 May 2019 07:06:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8BF6B0007
	for <linux-mm@kvack.org>; Sun, 26 May 2019 07:06:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so9591080pgo.14
        for <linux-mm@kvack.org>; Sun, 26 May 2019 04:06:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dnRlIwzLsh5gtE410Wzg4R0DjN2uPpGflfJ056ZS7Vo=;
        b=RgruyfAa5x0Uvk2MDBQGMhOgkpEqHKvTZ5cHnIIiSnondB/xv5/pjZz6oWel9T8EKM
         pImqMGEKZi15UgWmqeRF1NdCqa2NoBHlfPxu/7svHvbtXB/XelTXMiNKQCtiCJ104hCk
         bvodkvlz537jNQsIS9mgc5HXG7GUgO2yMPtbf9S0XspdRtPDoe45GhtdZ57w2e6mKdXj
         NedRWtaeXOUfC159pwXx7LZbyWCETknD0xgwj78g6gbXoBQpg/phABMNaBNXUohEfqr2
         KodzPnhCBfbnVaZSP3Ry/9TIvqvo+0rGGP+4Nafh9FpNTYqEq2wDAVMx96dDbqrpWzKZ
         qUUQ==
X-Gm-Message-State: APjAAAUP8GQqTDGuu5/dOBfWmz4fP5Z7/INxdMjjNw9TtULQ9wgGQ7r/
	n6vpK2sDA9F+HTb/+7cmhJV/NRmthndvWZo4b4p6Xcg++nQKdEyKoASmUoBzFI/gpDhMPEr/kzq
	gdY/m+2EzhazKiCt4EuPllhof7olP8Z1hdFU/lt3RD+vw15mMQgXQwrfxB0eCLg4qww==
X-Received: by 2002:a65:62c4:: with SMTP id m4mr28602261pgv.308.1558868796060;
        Sun, 26 May 2019 04:06:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+M95psW4OS3IzaSOuPv5YqOtychzDkb2qSHZkCh2wdNmzBaVUpPI8eVSHfgV0Q+lungf9
X-Received: by 2002:a65:62c4:: with SMTP id m4mr28602179pgv.308.1558868795232;
        Sun, 26 May 2019 04:06:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558868795; cv=none;
        d=google.com; s=arc-20160816;
        b=ZoPJg9bhUqu8ld3XYJWrQSgAKYw/c7aTodv6gBLCrl8O3hV9snsUqBsUPBoNDAQR93
         SaGrSKenA/elwuO3tgNFPqU6vf1n3iOQGfWyc/9+fIvM7TCaoeJLqSofa81T7zgawU7j
         JOVqqAU3D5MtvynJfTwMCp8WbyofkBAYF5PSTsPRMfOANnvYGZ4WGz2PPbh5MbanakmE
         zrnEb/28zoLWbd8NW37Pcuk5GIgrDzhUlyePQlwgw/MxyP+uk1Ck2fSBM2+jhmCiti8F
         84sfN8tNJkv/De0NScFL4mX9Rs50bVNhpMeDgcdwX12dCr1ZWafnv0l7pJdA2Axv90RJ
         pYVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dnRlIwzLsh5gtE410Wzg4R0DjN2uPpGflfJ056ZS7Vo=;
        b=yye0U4LYfMqNAMeztQMsIRTOjVD/wLL18WPOvUhTIjMTBni+dawrdyia/pC9uBdVJx
         YOaluZECjByDYvoTdudbUkz6KsqycrLNFn0+/jlvaYpgZu8D2hbR7E/lmmJLRizc2cEG
         hihwWf3vDoSmXFVOzcLimfYmZAKJ/g3ZPYp+EiYDvQKjsHb7RYSMN0pLuRQ3EfshtWFO
         FPtTAImmZoVAZ2oAdzJWOQ6Ok0C5D9OBZGt5BADyEQVBpVRW3NJ2W8Zb4jbkJmeClW0f
         OuBzefcPpsN1vtzCfFc9obRaQcQq1Z4yBXh2hLD5u9TLiocHspUzIMJgG2b5fWjgHqfg
         Wa9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KpKeoXxD;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d36si12596683pgb.452.2019.05.26.04.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 04:06:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KpKeoXxD;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dnRlIwzLsh5gtE410Wzg4R0DjN2uPpGflfJ056ZS7Vo=; b=KpKeoXxDjqBDfQZZgp1AuGzjs
	C3p5lYMN8SnDhpWYllf1E7TWYwBI6oGBT2jXgmJYCKD4gCtkUT6wAlQxetGESzhFLp0kixvl0PKz6
	sAIZ8McSchStRWXueMYMAzUEef1vD2eo20gCnaFS9GlxjNZ6NofnoZ95FC3RIG5QAZ5R47DmON+Qo
	JdOQPQ1LUXvgqEpgmOO5i6saVR6L0Xi+3VJ1CQlW12vxdRwBwl+0dLPYwev5/IQbIN2AjGvY27PsJ
	6Pv6/5pS3hIlEgR1RuK7uJxg+BLAGf0eWCGlaxQFawlyO5JV9eBonzUDeprQ1j6UJOqA3XCCfRY7o
	RH6eOeHcQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUqz2-00036Y-1M; Sun, 26 May 2019 11:06:32 +0000
Date: Sun, 26 May 2019 04:06:31 -0700
From: Matthew Wilcox <willy@infradead.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Jason Gunthorpe <jgg@ziepe.ca>, LKML <linux-kernel@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190526110631.GD1075@bombadil.infradead.org>
References: <20190525014522.8042-1-jhubbard@nvidia.com>
 <20190525014522.8042-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190525014522.8042-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 06:45:22PM -0700, john.hubbard@gmail.com wrote:
> For infiniband code that retains pages via get_user_pages*(),
> release those pages via the new put_user_page(), or
> put_user_pages*(), instead of put_page()

I have no objection to this particular patch, but ...

> This is a tiny part of the second step of fixing the problem described
> in [1]. The steps are:
> 
> 1) Provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem. Again, [1] provides details as to why that is
>    desirable.

I thought we agreed at LSFMM that the future is a new get_user_bvec()
/ put_user_bvec().  This is largely going to touch the same places as
step 2 in your list above.  Is it worth doing step 2?

One of the advantages of put_user_bvec() is that it would be quite easy
to miss a conversion from put_page() to put_user_page(), but it'll be
a type error to miss a conversion from put_page() to put_user_bvec().

