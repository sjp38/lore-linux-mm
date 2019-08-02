Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 979CEC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:31:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66ABA218BA
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66ABA218BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6B8F6B0003; Fri,  2 Aug 2019 04:31:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1DE56B0006; Fri,  2 Aug 2019 04:31:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C331D6B000A; Fri,  2 Aug 2019 04:31:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B45F6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:31:45 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id l16so17912037wmg.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:31:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I8+2yDSeuS9u7IuvSFqpHW254ROBjwDIGe/Bt1BzSjw=;
        b=khWaescIybradT9xteW0DeN/WgH38yBrqC6tW+vcnh/xKnGPddzoc6TK844JMB/mEy
         AvbPbdhkx6zus1ocVs+L41AWf2mtMFyCsnioIdYuXMMbJ0c8s4qmanPuyAubrL9sK42a
         uIYQdhSFjaP54b0vndtFFVO5X0mNtgDFEi1SXEQ2CeIrEV6VTw19i31KaxFs6pCGsIv1
         38D+0cdBHl3gcs05emapeC+j4EiXQ672nIKtj2Sc+YWbOEVO3wUD0bQKuozKCm93LD3A
         /LqVjNiDwG9sZ6ON2YPPh3AQrvdlL6S9tVHts52FGiel1wwVxj6Miyayoo7t8uruglLp
         aJmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXBSlcqRLy2eLXTHcJKJksph/NVBcFzNnbBprFcGJ1gmYDbndNk
	Yu0Oc9EAQS3IiunLA0Y/tcFDR++IuibI1yKdIfHaCyTBaX82sPTwKwRfLYa3z2rbBe+RtL3n1HV
	nVnu0KK3ikWaX2VX4lmShSyaONytiki+hHiaFNb/7jB3OklIn6mnP+wTwrX1RuBLNvQ==
X-Received: by 2002:a05:6000:12c8:: with SMTP id l8mr53008553wrx.72.1564734705086;
        Fri, 02 Aug 2019 01:31:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgKndNfYiKv4MBnHa/WXlrsgIrInmjgWXN2lqBOOp9VZbRdAne1opKbgcAkZZHWEqKmwT5
X-Received: by 2002:a05:6000:12c8:: with SMTP id l8mr53008451wrx.72.1564734704164;
        Fri, 02 Aug 2019 01:31:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564734704; cv=none;
        d=google.com; s=arc-20160816;
        b=Yz5f1WCnju6fBZQojpaI0HHOL232IlepOU3RsUQWytF0ZYqSy8iFbmhcx2OzJcvTCi
         NTfM2G941dkZ775l1VjeUt+YQw7dIEjMy0B3RguqoBYS4cIWZCrRsJ0lNmmAKBJC/mTm
         e/Vh/+NNv6Wo7Nl7OBs2uQCGRtkITY1zd23xMiEniGKYy/obvpvFoz4YighxNgp/d0HN
         hj6UZkW5oT1DToPqQ1B+Vhj9FCtOLdukNFTecV6iO8uTLxW6Avv/DiWgf7fsW03SoG6z
         ijfMtXhwC53Yxmdmtb7U/ID7W1Djh67iZOTbcUbxcAqo3kUtbNjniVYvMFbSmCzsK4/w
         AXDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I8+2yDSeuS9u7IuvSFqpHW254ROBjwDIGe/Bt1BzSjw=;
        b=nSY4189KWfLVI3XReAegn9Q+N0TObxT+V1zC/VmmGQBtKih7GeK2tCckfbYbcBiZi2
         vfsOJ+rMFiCdSNZvs/9u0iw5ZETlwbOZ6pbj8fqDomxiY++loCymeAOLTmdROX5jLKIq
         iEw5PN9L/d0vCLZ9D+CDFmIlTM7FLexbwl4vuU+GL6l12zpXDdwlXH+jFq/CiNgz5D6I
         h8l2ktZZp+2DvygmKNcx4NDB2hkdoWUmHCYPZ0v4k+y3Q4tr5RfxA2/3w3aCvqeAqBjT
         PXhnog7fOwfImXfHpq9D4JmFCEEqJXvI8jixRtC9qkHHIsr+4Gw0q5UCIbRILwrKdYSJ
         O+dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l2si54890131wmi.162.2019.08.02.01.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 01:31:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4B6D068C65; Fri,  2 Aug 2019 10:31:41 +0200 (CEST)
Date: Fri, 2 Aug 2019 10:31:41 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Christoph Hellwig <hch@lst.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v3 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Message-ID: <20190802083141.GA11000@lst.de>
References: <20190724232700.23327-1-rcampbell@nvidia.com> <20190724232700.23327-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724232700.23327-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Any reason the fixes haven't made it to mainline yet?

