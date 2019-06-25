Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8630C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:04:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 965022085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:04:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 965022085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140406B0006; Tue, 25 Jun 2019 03:04:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1DA8E0003; Tue, 25 Jun 2019 03:04:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFBA98E0002; Tue, 25 Jun 2019 03:04:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFCE86B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:04:00 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e8so7471536wrw.15
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:04:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=AyNXw6p3yv1+GVuM+mVZZtEHRmir93tU/vxlGQe9LW3bWCnh0O0KAR73rxGmaszCQW
         rU1dE5NqTE59KYl3bAmgmuVB353D4WCWkBrltCkwmf7OVMY2HlHjOCD5e3C7SpZgAhRj
         DK8deEpGKPXBVJ8RPr9vEce7DnCiYMTaLKUFxFHohxAgxc8BhrEU7GVQUWA5IhdeV9DT
         V/7BvETdp+4Fsy7ngkon8uUIOzFXY9qhL5r/+hURO5EZSRL4zgL09+JPOGNPHU+c1pPY
         GZiHhg3k1vvk/G+LTiSQOj7d2W2lghZVJTOasP/qm+BEfAMYvBHgu3+a1LNR8AC39ond
         kOEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVJAbw+wUkyPiEnE0bFZG/LON5j1UjRQIkJKoKbAk6DWLXceVTU
	/M21qfRj47swQo1Gzx5Bx2QhF4PG29yLjrnpwAGUwBvyBB7j9iZo4CJg2TmmAEAWQ/AixaOOUNx
	GEBEIbwXPWONOckNYjIyG0DUMWfgVUe5bvvnVk6wtKFY+SCxjWV8lKbCRCneGpRQBMg==
X-Received: by 2002:a1c:a7ca:: with SMTP id q193mr20098753wme.150.1561446240296;
        Tue, 25 Jun 2019 00:04:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzlfQJrHAqRHGp6SUIx4JjjpMzWVwsYXoY484yhiz+LvZ216NFJb/KUZzyq5z9M3otRiQf
X-Received: by 2002:a1c:a7ca:: with SMTP id q193mr20098712wme.150.1561446239696;
        Tue, 25 Jun 2019 00:03:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561446239; cv=none;
        d=google.com; s=arc-20160816;
        b=JCx40RyQC89AeFLc7e83B2/lV4qLAhXDWeMmRUAOtYknadbQ+meP7ctt7etKu6mNTx
         DiQOfjTSOaGUKVaBeLLAVLmt3RpQ1/gDmvKZyfH5GdxPXXf9b3wke3wVMuuom2ZaqVE1
         VeiVDdgVT0iVc0uuWghsFvhJId83JCG6O5h+uDHCfGm66PAooACkl0I/YkicflfFKkLl
         6zXjoZ89PSchwBnh1tMNglqTQcWnPNpthTq44sFasgv4B9A6Pgtb29jTGV3mT1HrI+OK
         VGDEI8WVCo1gIZfdNUOENQoc4y0qHK+dxtFePMG6xYTGiE2tfSrP0S9dJFgIO9VKliqy
         cxPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=Zx+8StzrTUfk7cCNKzZsqaDqr08qjQx4HdGr9PNuGIH3V+AWyw9zpDrGPdWSGGluNI
         TcYt8TephtyKFyMVDzVmgE2HkZdEKbu+ZME98HGJsTfmSP/HUCQ5pSCwPk+RwpPjf2TM
         PsoxHeSogWIfaSBrIoA4YN1mgERNpAU5eSA41rwHJrnttU1iEBy5C2sFL/TCErFTDMf4
         g8YnfCGEo5DVxD0FkR+47pQgm0hE/Kxg80fhxf2Glu5u9gf9cWYTLAGwYuQZrs3eDoFp
         d9Zr+nyUjiQpl9rQmdKEzX0+jvEeGO/d0Q4ePogNeey7SWglNvGnsQdGX5OMhQjQi6aY
         HdJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r22si1257768wmc.48.2019.06.25.00.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:03:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 6C3E668B02; Tue, 25 Jun 2019 09:03:29 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:03:29 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>, Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v4 hmm 11/12] mm/hmm: Remove confusing comment and
 logic from hmm_release
Message-ID: <20190625070329.GB30123@lst.de>
References: <20190624210110.5098-1-jgg@ziepe.ca> <20190624210110.5098-12-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624210110.5098-12-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

