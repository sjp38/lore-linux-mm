Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D01F7C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97ECA217FA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:59:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97ECA217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12FDF6B000A; Thu, 25 Apr 2019 03:59:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B7646B000C; Thu, 25 Apr 2019 03:59:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9A576B000D; Thu, 25 Apr 2019 03:59:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A87186B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:59:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r7so10684251wrc.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:59:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xUzHLbN4Yt2yT3/WWChiQXpO7i4TsCJa4AfULRKV5pY=;
        b=sbC6qQwyOzYWrV/KFHUw4K15R5Clx80ofcSpRgKN2U8DNWqJqmGcwx3Q+Bra46wW+o
         LLO759YsLYvxBnMGYI0jJQ/vNBeEEjlnOKPVF3nXEJb9xba98bgsHITJcClxg92A0Zpu
         nUs2T3EnFCWNQ5Q8h2Mma7Pxnp1ICpWp4YpatU2ttOIrGRHVdmWsP+GNKYe/GrRZmH1F
         xrJ/UBzEi8N4J2x75AKZIAlmIZKrOHcmEkqKG0vvqteAt5+pzr/nvRjFe+S9HbJkrF9+
         Px2/z/EBUMAcn30sSB6eF/PDlz+PT/r+4233FqPN9I3gwK8YRmb6rv/Z6NydS2uYxIQH
         3y1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW/65Vze9sbs83mupuXVusVuSNxeyXgT40v97EXxmQUbs4/EK96
	C2FuGNf8ty7F3x8uesM1p0sy4jfXDxb01Q+WuQl5A72yiNLephvEQw6OGiZu6naDJ7rtVXNWi3a
	Xy2kUCF2q28UpPlE2mthpsnEhWMpGUUnL+vvgL0eFm437kBHTM4j8ghs58mrayYK5Nw==
X-Received: by 2002:a5d:434c:: with SMTP id u12mr26132273wrr.92.1556179189248;
        Thu, 25 Apr 2019 00:59:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsAwTyo7tPOvl7iedSOsBBhOEQD1B18szQilRqAk8TaPGTXg6hQQNhRxls6Td89pAlmlZx
X-Received: by 2002:a5d:434c:: with SMTP id u12mr26132235wrr.92.1556179188567;
        Thu, 25 Apr 2019 00:59:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556179188; cv=none;
        d=google.com; s=arc-20160816;
        b=A+XdmMPP77/756CtK1MP8EtJXwChqoPkeEY1pOlQl9GvJ1apXgEzQiary3wFS2fXGB
         CM/zfsX6GZVnvkXn8DMf03WF2ph3BD25+o6xcjwWKCH2Eebl1WqN25TPL+2qgRkxuruP
         YFQcQ1s6zJBk8OPNBMPzUPcekE5sZ+jBItFO6YVyLawfoWLFQsSUyA+5k7CrmCO+UAl9
         RczPi0dqS41IXd70Ox7tdRF70uwU1CIbejsTA/Enq3spAOXJhpCNDFO7GoGblTOGPod8
         SJA2rHIyKMqysp8vnDAmUEsJj/yunNEqeC5DLTW+26oc/PCwdyTVxTJuIdcXzMFHkQGz
         WRNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xUzHLbN4Yt2yT3/WWChiQXpO7i4TsCJa4AfULRKV5pY=;
        b=Xrj+Gk0Sm5ifMiAIZGKlBYkI/xdv4Zn81RbrX3xD1HO6AWDXq4aawlcCb8eDnrt6kH
         FVY4HtQg95pUJsDqAhDu5McmgZkT18k2S5CSGSDKBW8ka5uVfuQ7x77SR5ajIRUTPsur
         oPYIviqqkpb81WEz5IAXgdiW2mtr1EVMQVI4a6VZ+aHMBZy9W4c+F0KeYBojZfnayVTc
         UtjRQD+HrVcC88J0rgzLITWZUU09p03acgL3wHU4LGZn9mJcZQcOfCsxgTPrZf5i5w2j
         QI/zigzE4iuMGbnMSpLFdJuu+4BD/pj85nxgZigOiy1T/INtVgPJ5L4poEN3cNZg3UF3
         U6Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v4si14347767wmj.132.2019.04.25.00.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:59:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 689A368AFE; Thu, 25 Apr 2019 09:59:33 +0200 (CEST)
Date: Thu, 25 Apr 2019 09:59:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] iomap: Add a page_prepare callback
Message-ID: <20190425075933.GA9374@lst.de>
References: <20190424171804.4305-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424171804.4305-1-agruenba@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 07:18:03PM +0200, Andreas Gruenbacher wrote:
> Add a page_prepare calback that's called before a page is written to.  This
> will be used by gfs2 to start a transaction in page_prepare and end it in
> page_done.  Other filesystems that implement data journaling will require the
> same kind of mechanism.

This looks basically fine to me.  But I think it would be nicer to
add a iomap_page_ops structure so that we don't have to add more
pointers directly to the iomap.  We can make that struct pointer const
also to avoid runtime overwriting attacks.

