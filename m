Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C70C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:02:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9ACD20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:02:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Fz9mT5h+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9ACD20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C506B000A; Tue,  6 Aug 2019 14:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DDCC6B000C; Tue,  6 Aug 2019 14:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CC5B6B000D; Tue,  6 Aug 2019 14:02:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAD56B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:02:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d11so76509635qkb.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:02:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DWmSMnF3B1mTPtWIyEYX2euOl5QowlPflL5LrFAqjMw=;
        b=WpB3R6yppVtM+zb3M54Rdf3akA0u/jv7HoAHNPKONeKxrrmLUPgX/r1FXzI89xU7gL
         az8fOAgPF/jQjmzk3wHwA8oljx0m3RKKpzcg5Z77Sxl3xciGrdi7NWPZfKsHN4/HO/Q9
         z0qaxGY56IJzB+SIf6BrVmRB/X4AGUH2E3JGyhZSfev/r64HBfmjoDLhmrxMsEDG9WO6
         vMWYjs7TIyKwCsFYvFfYlvgsdjGG6ocq3leCc5rOlui1Jz0DLvqGXl+nxGq+6H6X4ZGU
         dZQfS/dPxLqKsIt8+dTX1bt0kDKbq2liGIaa3xDdXOEubHYivyCgZFaoZu6TakXwGywG
         u4Hg==
X-Gm-Message-State: APjAAAUMz7XceNsVddd4j9i9LbP17YHzpNnTPITlcpoEcEN6HhR+fKUt
	Fsu6LrUE4hT6rdQh4pxrBpjDJszHYNY88V9CDcTWrLt8gudIdjTBST1bBbm8ZCAwcaHUsRsVx2n
	WNMhSp/clb4YT8pk+GwXCMRtDU6friUBbhEIu4cnx8eXWnvWfkRRiS1QAusgUB8mAuw==
X-Received: by 2002:a05:620a:15ce:: with SMTP id o14mr4582057qkm.30.1565114530813;
        Tue, 06 Aug 2019 11:02:10 -0700 (PDT)
X-Received: by 2002:a05:620a:15ce:: with SMTP id o14mr4582014qkm.30.1565114530374;
        Tue, 06 Aug 2019 11:02:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565114530; cv=none;
        d=google.com; s=arc-20160816;
        b=DcBKxkqT/aX0Xdk+FrP6siuo2isJxfvcnFlGnWJT6MjLh1Hi6jWHtPxROsOZAMRdMq
         cmchZ4LcxV4JIvmTWP9Co6CTSRVY0ttayNaL5kSEcSx71nTdRiaDqCo+qUDYgtURJEbk
         LlrNvoFn8ZlBQVUgBemuON1/AJyrF//Z4vCQEEkIAUKXpf/QxhST+kYULF3Zbc8cy0wM
         Gb+64d1206/2RWxy0nqGyyj0h9XTDmLXIrXCtxnIn9a2qrwOF+hJa8J75ImI5BZtJPoK
         y1wwmtE+9YhUZpYqfVH5fT3Ofp/Zzw+9tYbFmkCpw+OPDSi794lb36o+HwEunaBlmOZ3
         2dsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DWmSMnF3B1mTPtWIyEYX2euOl5QowlPflL5LrFAqjMw=;
        b=HtzsNNDqWbh5XTKbPnbjqUyM+Sp+KrWCXnX5E5WF6GR1LdzKIQqBYzLRn1wDSAZtMD
         r8ASRTEH9JtuQPTdegxPYanpR3OAZogQ+FTWZ2JioGdW6IlP2MTUPfg1GaOD7YeWjPFV
         eJyLxheNaKWqih3wqaNTOICeRf7wpBzmjp4Zd68/YQcMfumHPBPKX3hWbgV8sn9a84y+
         4KW8HyF9sAe7NXH/UVOvRGoJO/wha7PnSmMULGSAJgZ1oSmsq5FWkTL/8Asx8hoAvkDc
         Sr6gOyPJ+szwKh4RrShUeRASjTXoAgSEXEJA4OdyPWwC33Y0xUfrSfny/ijjSzByyoFL
         IRAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Fz9mT5h+;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor114165395qta.62.2019.08.06.11.02.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 11:02:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Fz9mT5h+;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DWmSMnF3B1mTPtWIyEYX2euOl5QowlPflL5LrFAqjMw=;
        b=Fz9mT5h+F2iLSvCsBQC5ggiqblN5sutWqjuhuF03Psd+Uf9SPIthU1SFjsJOpswgqI
         i/rgIdKvSW+0tmW7prrn9Y9533G5r4E6d8zM2DnGZ+TNNPM1MBH1FT1zMnZwkyxWU56W
         iIxNzxmjUm0QE0MLJTbJe3z6JqTvYF91SW6QufY/zMDl+9YGG4y5cVhS4ePPcReybl3S
         5KnATeu6yNsS0v/Exp3ApYHy7cwB4/w0c77CJqZUqewRB2Fv001+6QZuzn3886W/04vb
         HuXkgysTL1jkEq+Yt2WQvBYWRBxT7DYd/4ML1Ga5aZt50ou9KZTiM8DcK7BJNDl2Ss0U
         6iSw==
X-Google-Smtp-Source: APXvYqzwT9xNxemQscVlJmSlpGsNQA9yiKA1TtYWgT1CZ65aDe7RTogerUHwfzBX65WGTnxLLbQenA==
X-Received: by 2002:ac8:f99:: with SMTP id b25mr4258745qtk.142.1565114530121;
        Tue, 06 Aug 2019 11:02:10 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id w10sm263879qts.77.2019.08.06.11.02.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 11:02:09 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv3mj-0000H9-63; Tue, 06 Aug 2019 15:02:09 -0300
Date: Tue, 6 Aug 2019 15:02:09 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 08/15] mm: remove the mask variable in
 hmm_vma_walk_hugetlb_entry
Message-ID: <20190806180209.GN11627@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160554.14046-9-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:05:46PM +0300, Christoph Hellwig wrote:
> The pagewalk code already passes the value as the hmask parameter.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  mm/hmm.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

