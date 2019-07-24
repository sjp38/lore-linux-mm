Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27C9EC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 05:41:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC7182253D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 05:41:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC7182253D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 508566B0003; Wed, 24 Jul 2019 01:41:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 490F06B0005; Wed, 24 Jul 2019 01:41:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3597F8E0002; Wed, 24 Jul 2019 01:41:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F13C36B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:41:25 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p13so21821094wru.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 22:41:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6myo2V5Wcm7a6T80pjYDS9nkwm7Etwa8PcEvkBNAk24=;
        b=mQtb2np9mQ+12ag+GJ//EzBNoNdXLd02SeffvLV0ZJfeulcQkdXbQ1J9ZLG0TnlYzO
         tFIpz5smwrpuZ/7Gq4Tkp1iYVfDn+cf+Q5sdyDh5RqWoMWhXVs/qHr61upgmGj1unnoH
         9CCejwyapbICT+o9xLO+jR9tlHlrlbuflrnBameykTPOfm/YIuUxmoOFrxrD2SLUkyGS
         UrPt8TtfEbF4/+p9hdQGNge2Wct2snqziPvayMb7kIbYVRdceNjCU4w1IemwYLAjHucg
         8dYAudvdmUnNfnNvyVxi62RbVFT1j/as0SyC4TV5iLnDRkBn5Uj0csxaRutXUoCvdINi
         oN5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVuHxQeSrNrGT2MYNlO4EgsyraxpSQ8h4QYogqimWjKE5N41vIp
	8+VrO95FRYBTQn5fMtVCcOLMov2hj1WhlBKVmYmnQtTLWdghxnTFAoIVRv6pe+bjUXuOhjWuah7
	FqihRWKx1sD+XDNyeFAOwygnmnl3UOTqe0jLZKtqzm7xPfkIZBiBi318EYLpKJxQczA==
X-Received: by 2002:adf:cf0d:: with SMTP id o13mr38806518wrj.291.1563946885437;
        Tue, 23 Jul 2019 22:41:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ/fUWnE6Ogv2Wtjr1jvbQ1C+oh28d9MvYj376p0Z8b3qB2dkR5+J7Kk5deZBbSl9QY3rT
X-Received: by 2002:adf:cf0d:: with SMTP id o13mr38806468wrj.291.1563946884749;
        Tue, 23 Jul 2019 22:41:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563946884; cv=none;
        d=google.com; s=arc-20160816;
        b=MkDDsq4x/FbrAG8zpfv7+nGlyl6rkme4RyOs6QueEt9uqXQWN/a0oTJcIqwfELNzUi
         /pPMlCFkotMEGsnEdhQQuH/cnkBI+kV2PaCGoH0/3Bk5pBYyVxTjgSv4Gc7G2go9dcby
         kruxr8cRCiHp4V9mMgDNGGcwn/qUmv6+fxQ239u1RSqkacCwsMvJPKDBqgaeJTFKXbj/
         uTI4v8e3EeEvK8WYPn+Rm5obtnw07mstlGiGnK9TtLJmfh6be7ftrfAQk0O5b+WjQOQs
         o58h4RtnrDKFDle4t/WFzu7oQL6qOpTBorTAbzYiCRbaoyxyjV9JMTpstot0T6MFG/ww
         OW8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6myo2V5Wcm7a6T80pjYDS9nkwm7Etwa8PcEvkBNAk24=;
        b=JdUiBo9GIH4DNdSTaqBxdUTEwLrRRzOrn1EUG5xJiD/VvmTS/TYiFEp2VkvnQHvUIF
         Lcg00JcMc0cCCsAvICDEmZ2KHtIygqfRKEeQcIxSZKhwLRCVOUyIT1u2JWCfszuuTP61
         8ZHQfSx3mjqYd9TcWcq1cfQAXx8g5LuqnR8dWJH7qJdpJKlLTol7m9qj1/+Ec5sWw+pd
         Qot24cZe+MeguFGz6GB5l9Y8JrLZCmszTArHvxic9DuPyZWADuJbaY9MChwBtb+nJZzE
         ekeer36vIzUlgDelBsacqtOJ4WU5Wk8QD4/W7EtB7pgj47x3WY9DeL7rgTyhfq1HLozP
         ooZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v3si32445586wrd.344.2019.07.23.22.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 22:41:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 72F3D68B02; Wed, 24 Jul 2019 07:41:23 +0200 (CEST)
Date: Wed, 24 Jul 2019 07:41:23 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] mm/hmm: a few more C style and comment clean ups
Message-ID: <20190724054123.GA685@lst.de>
References: <20190723233016.26403-1-rcampbell@nvidia.com> <20190723233016.26403-2-rcampbell@nvidia.com> <20190723235747.GP15331@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723235747.GP15331@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 11:57:52PM +0000, Jason Gunthorpe wrote:
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 16b6731a34db79..3d8cdfb67a6ab8 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -285,8 +285,9 @@ struct hmm_vma_walk {
>  	struct hmm_range	*range;
>  	struct dev_pagemap	*pgmap;
>  	unsigned long		last;
> -	bool			fault;
> -	bool			block;
> +	bool			fault : 1;
> +	bool			block : 1;
> +	bool			hugetlb : 1;

I don't think we should even keep these bools around.  I have something
like this hiding in a branche, which properly cleans much of this up:

http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-dma-cleanup

Notably:

http://git.infradead.org/users/hch/misc.git/commitdiff/2abdc0ac8f9f32149246957121ebccbe5c0a729d

http://git.infradead.org/users/hch/misc.git/commitdiff/a34ccd30ee8a8a3111d9e91711c12901ed7dea74

http://git.infradead.org/users/hch/misc.git/commitdiff/81f442ebac7170815af7770a1efa9c4ab662137e

This doesn't go all the way yet - the page_walk infrastructure is
built around the idea of doing its own vma lookups, and we should
eventually kill the lookup inside hmm entirely. 

