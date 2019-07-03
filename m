Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E7A4C5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:03:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5565821E6A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:03:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5565821E6A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C89606B0003; Tue,  2 Jul 2019 20:03:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36718E0003; Tue,  2 Jul 2019 20:03:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4CB08E0001; Tue,  2 Jul 2019 20:03:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF096B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 20:03:36 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g8so247393wrw.2
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 17:03:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ipa9lxzq0WQWKa7Ttaj521IqBqfFrEN1GLxckouUYjU=;
        b=ivMoXkNKBCs5UDy8LsLKL5mU8+GXWhNtXs5E3jJiEiNbPCYT5DefZltr0s6BzK0yjw
         LG1O/eMIjFzYsW6xlJnHKbRYChvcF5R5Y7MwbeFuVAT61Qg34/nhbkPVfCcVh2miUylr
         TbTi9w3wit2g7RGCdPhoV9rQqILTuzrhNq/oLc3Bf26UI0DIYK5Hf1Kb12untj1KJh9h
         Oo1fPsQAyyG/bSlLG8tXILtNtPbCiDSXJ6yil7Q5y6OKTAKfNFdodcjdpAi+8zVbJ93Z
         4mtAKlowifIKWav+zkJ6LTYurkKQ1NxSe2Vk13u3ouZR9ENE9d1u6FsJpV3KkfaE/w7/
         Cbqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW9q2O6R9i4KDIt6aD0DXZ97EoIl4UvFTjuLIARMdiEBDGPaBHd
	1vcoGqdGNMl3YrzhutJgLmxMOKkJc4CvPsoAr1IL97Ts75bAQmyvQ4nHiZB5WRysZHsxI5v5VDe
	YXB4zmL2xQoRsGZTprv4to/TrGjWMuzT3KrFE4rxPtyB3hYFqB+e9kE4hilVlR1aw0A==
X-Received: by 2002:adf:f30c:: with SMTP id i12mr3233991wro.17.1562112216086;
        Tue, 02 Jul 2019 17:03:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOGCeq8eBb10vnsHd+VFmUdUq7cfBU46PORWLdQLNhS9C+OKBTBfeub0Nh4PQgov/U4Wph
X-Received: by 2002:adf:f30c:: with SMTP id i12mr3233953wro.17.1562112215042;
        Tue, 02 Jul 2019 17:03:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562112215; cv=none;
        d=google.com; s=arc-20160816;
        b=cYqvbpJ3xhnI5qvX6LOFp4wXM919qSlSPYDA2Ohj6fHukrcs8z/v0l07mcW+Ha6wSV
         C8e68jhHGtIxShKr1IBQ8K1nJv4eE/rCjqLGqkGnmtoRCjvRjiU5T5eDo4Tlsz0ehwTx
         NZ5FdpNWk6aveC1c85egjxlu0aofJId6nQSyXb6PsCaG5J7VUtXZ1XDn8fwdYYAU2nXn
         cJ6wMulkuDN+M2bbcksWs1W5f00wvRiWzxLO6cAI9m2t5C6tbp8T3rNNkZQ3vVK7vQFy
         rBnnGM51riqZnUU040F+0KrH+UZoxfLcz4/GgHcb1jQN2OPjwdSmH+enZmGfSNcGKe+M
         ciqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ipa9lxzq0WQWKa7Ttaj521IqBqfFrEN1GLxckouUYjU=;
        b=zD+s3JZc5+ViQeJMyu53S4G6yFjbeC23Rqy3mPgCx9yuk+TzWj/idYM1tLzJzJPvIN
         Wj3gWTKniIzf2lMmdffuL+irZ66MJi3WdehW27iMGap8TOs5urh7gf6nRsGGGYv7sZCC
         PggT+FxYDCqK1jRRWs5FKWI5aPlHxJK1Ah9fD168n6KFvtIdHBakef4L242uNQHHlXyp
         IjGKX+dglbiZP9mT3PycGi7KoJinY+RrxtSlioorZrZueitzSDAeRNPMDbqaGi54jfHr
         Nr+SBu+nRUNY9ocJ/F7L11iaE4yYb0V3jYB+hAFj8zeTN0cpdobJWk1lPBXoRYduRyw5
         3gQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x8si295282wmk.26.2019.07.02.17.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 17:03:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1A7B468CEC; Wed,  3 Jul 2019 02:03:34 +0200 (CEST)
Date: Wed, 3 Jul 2019 02:03:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Message-ID: <20190703000333.GA29316@lst.de>
References: <20190608001452.7922-1-rcampbell@nvidia.com> <20190702195317.GT31718@mellanox.com> <20190702224912.GA24043@lst.de> <20190702225911.GA11833@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190702225911.GA11833@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 10:59:16PM +0000, Jason Gunthorpe wrote:
> > As this creates a somewhat hairy conflict for amdgpu, wouldn't it be
> > a better idea to wait a bit and apply it first thing for next merge
> > window?
> 
> My thinking is that AMD GPU already has a monster conflict from this:
> 
>  int hmm_range_register(struct hmm_range *range,
> -                      struct mm_struct *mm,
> +                      struct hmm_mirror *mirror,
>                        unsigned long start,
>                        unsigned long end,
>                        unsigned page_shift);

Well, that seems like a relatively easy to fix conflict, at least as
long as you have the mirror easily available.  The notifier change
on the other hand basically requires rewriting about two dozen lines
of code entirely.

