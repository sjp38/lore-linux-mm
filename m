Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 297C0C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFCD5217D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:23:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFCD5217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 726F76B0006; Fri, 26 Jul 2019 02:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D8C16B0007; Fri, 26 Jul 2019 02:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EDA38E0002; Fri, 26 Jul 2019 02:23:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA0A6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:23:25 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y127so12045804wmd.0
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:23:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MMFBgNBytIAekUa1DEmejYIxqek9Tvj4fJU4XerW51U=;
        b=ba20au4eG2QG7nqzpYgs6DY9bfzCjMKVES41nOPsrGuXi3i9JyGsyLjKKn0PNv63lA
         v89RCrg+rZ+He5u/CO0fYx+r/4aol/QA29OCjmAl68c8IC+r+u9CY+hrrxVEhSqYLUiY
         9NDOkvYOUcRoaJntGPRcUAf2AiuV7TIQBCYcrggXlVaaFPXjeIq5fp/eN3tIkbtw0ol/
         nkOrg1rxPQrbwacIY2Vt9Ur1sDRfeRFHzolz+rOi3P1xMr+bCGlSCexTJpL43SqvZID2
         nV3+Y5wUB+dYC27HlH+TaPsPSnQBz/GZsiDy2TGKrwDHVLPksYzoQnwzSB/3WrTGqJfC
         VW8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWDEW1XATUE7MEg6n8dfUWamiiOm0P36oJi2RG0FfwpIKrPifds
	2VmiEFLnasIJd4zX0pCwPtjtPBWn1jKgFwedFS0fzitGC7OyBtVi20E1OQIyGZJmeHU3ybqlfqB
	xXhBCVUF7pJoY1EHcNZDQ0boEq6tR2lWvGzDauPdRR27YUuXTPt8sEHCLHfj/XotF2A==
X-Received: by 2002:adf:f544:: with SMTP id j4mr99725160wrp.150.1564122204723;
        Thu, 25 Jul 2019 23:23:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysoED4iMZWyu95s68z5Lc1HK5wvT7Gg/3lONFr8A6mzJSW8/9c+6E5NrLwIGi1ndx/gLBK
X-Received: by 2002:adf:f544:: with SMTP id j4mr99725040wrp.150.1564122203713;
        Thu, 25 Jul 2019 23:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564122203; cv=none;
        d=google.com; s=arc-20160816;
        b=lNvLOC6t8Ph0RK21GRYJdnMII9erxDRi/8pT7VVWERz9+wG6dJ9DsBVXJf7GlaUeTP
         z5yOlE25us2Fp8/rgjjUNePploa7PCw051nNB6DZEwmYuXi7XvgrpSnw0DT4TIm40Gm8
         3O9Vd/i+v5vI1tnQD75SU8cTTBImHTD05OeToxMeIu/+faxR3u1Rgd3qYCfhVkfgRqe7
         WysszondszPPlCsPjhey6xBveaORGf7KHZ7VoxazEsKj3ylv9nRwhAWanvdAXXkFeXhf
         RVRHiAl9lJF7XCa2ygnYOYCiiRf5Es+OaewiSxN1ICtHUMTLPiM4/4DQCQSlbe0ZKdrh
         OHiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MMFBgNBytIAekUa1DEmejYIxqek9Tvj4fJU4XerW51U=;
        b=XWQRmIm88799UPKwANk3fcN7VrPv3Q4Ww9MGF2zlXE/o24m7GTyWeHDXUQg14fbAjv
         uZ/pO3d++7JDLQuoPfoovvxcdFLRx3BbA3ChWVzB0dQx8LWN3WZ50U2+Y7f/AothBVL/
         DoCyaZS6c5CB4w1e0S9WmKzsk1ZBxqmqtdOpM01I7apOkfCsfOet3DXad8NPGy5UITBv
         sZg8D5k4UIfs/407Bx6fyvR07Sycot0G5tAYtfCceLloU/SrorsFYsNe6Nl1IModno9m
         v4oUp1PXanLI1GTIeDgct2EXoD7NRP0leefMAt6I8muehr0aHDSTqORjdr/W4RZGQIZN
         1IYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w11si49914006wrm.129.2019.07.25.23.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 23:23:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2300068B02; Fri, 26 Jul 2019 08:23:21 +0200 (CEST)
Date: Fri, 26 Jul 2019 08:23:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 2/7] mm/hmm: a few more C style and comment clean ups
Message-ID: <20190726062320.GA22881@lst.de>
References: <20190726005650.2566-1-rcampbell@nvidia.com> <20190726005650.2566-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726005650.2566-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Note: it seems like you've only CCed me on patches 2-7, but not on the
cover letter and patch 1.  I'll try to find them later, but to make Ccs
useful they should normally cover the whole series.

Otherwise this looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>

