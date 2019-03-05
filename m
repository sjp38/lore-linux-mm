Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B7EC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 00:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 199DA20675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 00:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cIbA4txX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 199DA20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A67B38E0003; Mon,  4 Mar 2019 19:53:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EC9F8E0001; Mon,  4 Mar 2019 19:53:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4C78E0003; Mon,  4 Mar 2019 19:53:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0098E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 19:53:42 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id o56so6777088qto.9
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 16:53:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XVYt//8tLSfx+WH6Lmq9iHXTEUimc3qP6GGB8yuMZP4=;
        b=ipoRK4VWJ9uFRLikR/sSsVDNeiaFbfyA1UOUMR+UzXACBonRPAa04ee5e8ciK+OmEU
         OoYo4KrRtcgBpoBUnBUL2b1N5PRIgl4Kmce0Mqi45q2MVqQGuRe3kjDME2+gs5kS0O0J
         93T/EDU38Aj4PISqcMrwx4YI1ijFQ+g7XD6trZqhtH7QD/pMnBEFf4SPt+2dembyr4/m
         R1vZRcwfjuZv0iBQgtdnhsEuyCiTlyfWvWfYTye3ktLWVV62CtdQ1r4baJWiKXII3kwp
         GsYQ1ECZThZ8GG4geH8B1dHFT0FO7C0LzYFgFlubxwtSiCosf1DxMyhgyaNbKwSzEif6
         vRmw==
X-Gm-Message-State: APjAAAXDm0/UFEwY2XrUXtYLd/AiGw0fCBgtnU3sdoOPfFlnwvnmbwFd
	S4VQxv5bE6yhg4bdNC+9f2CTOiz04YxEnss8GDgpDVAWQwMdFHnsGDu6W5JHm6X6Ipe5MFWE2p2
	pKVlXHRLzodGWBuBPlzeTfAqgqsdoUe8tXUXn0xJpwLYqTvM1ixDSYcw5vDb13mFMOC6GbVCjwd
	5T097H5AKCfi/Tlcy+6kpJYlZy6vTE2lNJ0giO9hnQEGq0Rs+GBcnh1zG+6hoPLDCKUck41wCbr
	yFSLcDc9jjtXeZbWSbuX7o8gUeAC3aldVHGMs/Y7ewwcGVarsh38UukI8NcEg0YfXKKBg7xAnxK
	mufkldmqgIzudDJkVBsrFzM5Grla5LxVlBFfVe3D1EuTV6tpcJ08Zsmsodc8HoW725QFHPyN8gw
	7
X-Received: by 2002:a37:e50c:: with SMTP id e12mr15539907qkg.327.1551747222019;
        Mon, 04 Mar 2019 16:53:42 -0800 (PST)
X-Received: by 2002:a37:e50c:: with SMTP id e12mr15539882qkg.327.1551747221440;
        Mon, 04 Mar 2019 16:53:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551747221; cv=none;
        d=google.com; s=arc-20160816;
        b=Ho42U20SMwWxHoCRJf49Rx2jpmHkqyUQH+L0u0nXiJRfR9LGakGT9iZ1XA6CydzBuL
         F02LdxDSgG6wCQEEG30eNDoKz+YIHHz8fa2P+tRosPqQlLB1UCsikTXrJwkkHma92nA/
         0k9r81oj6PjTbqCD9yp5mqogCAdZff/9UFY57PjT46wnAIisbggTm9xpM4wsERojYIyc
         fOzHTQcAZuWU/mWSAU2IgYehOBoaOQ0U0BIWorDtfac3LjBk8Yk2pFrF8JnkT7r5JctI
         V7cE2kVqCf/Sdw9lfSC9KIodAiv1i+xqh6SaVXMly2NpmAm6920hvkdBFTxWH/cQ4Rq/
         N95Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XVYt//8tLSfx+WH6Lmq9iHXTEUimc3qP6GGB8yuMZP4=;
        b=PC7MRpEkJla1OqfOYFEi3FQ7nUpKeojL5m9pphYo+TNubguUmcHQ1/dwpcv5/zXmdx
         KrMk+vefFcbCUzrx+MSBBjhJkivX8GZOg0d9SiTcGBZ9RNRWXrVu409NDmc89NCflOat
         8AtCwkd5rrhBwT/VEZ88K74NYHZT+/6yY+/g3hYrbn6kuM/gg7MuiRje6O4o/+EEAOMG
         3Me8bYaf8wvjSV2FDeRzFeM4yO7SeQZ6eAJGsQs2aPNotvD+MoqusWwVS6mH+i0/iRFT
         b1o/bOvmQ0G7SOxZWKDt4R9xtfhFq7BgQTO/jFrS+gDVYm1NOEZ4mrWJL4MAT6ZA9/s1
         UOzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cIbA4txX;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 54sor8900900qtu.3.2019.03.04.16.53.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 16:53:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cIbA4txX;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XVYt//8tLSfx+WH6Lmq9iHXTEUimc3qP6GGB8yuMZP4=;
        b=cIbA4txXePxhYRMosF0K4Lf0pYeh5EsSFPuqs/QO/VWfnll6mD6fAdE5bLAsxDDV8b
         pMcaqaJ3cAphmez5ynHwcu+nAOnX0lNGpa7CfwAzx/1IBdJnNYHnEs0njSfozkQkDnv/
         /BDWuTYiFElCsWZmnR2f6Eftcm3hsGd/oyx8aEzIscAlTcejvxOn6sJPgios4EMa8IiL
         l4INWPvsR6ZjJr6mAb5ZQR8azH8ilI7Fvz8bLkbr+OXB0/VIqrZFmE581eaxUEa3760i
         o773UgVIyzIPBn4hPNDtc3ZZbNSV3pZYH07dyPgrK9oDQdUm6/M/bazP0dozLWDejXAZ
         kJEg==
X-Google-Smtp-Source: APXvYqwgYquIrGrypPfGh12coX509Dw+mf6crd2NMr+KYucqtQsXeX7lvPZECuSr4ZCtq072yEeFpw==
X-Received: by 2002:ac8:2b2e:: with SMTP id 43mr16897084qtu.33.1551747221098;
        Mon, 04 Mar 2019 16:53:41 -0800 (PST)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id d80sm4140972qkg.83.2019.03.04.16.53.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Mar 2019 16:53:40 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h0yKw-0002jB-Vl; Mon, 04 Mar 2019 20:53:38 -0400
Date: Mon, 4 Mar 2019 20:53:38 -0400
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190305005338.GK8613@ziepe.ca>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <20190303165550.GB27123@iweiny-DESK2.sc.intel.com>
 <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 03:11:05PM -0800, John Hubbard wrote:

> get_user_page(): increments page->_refcount by a large amount (1024)
> 
> put_user_page(): decrements page->_refcount by a large amount (1024)
> 
> ...and just stop doing the odd (to me) technique of incrementing once for
> each tail page. I cannot see any reason why that's actually required, as
> opposed to just "raise the page->_refcount enough to avoid losing the head
> page too soon".

I'd very much like to see this in the infiniband umem code - the extra
work and cost of touching every page in a huge page is very much
undesired.

Jason

