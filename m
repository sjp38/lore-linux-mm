Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 538A5C46470
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:43:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A605215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:43:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A605215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C6C6B0008; Mon, 29 Apr 2019 15:43:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D82C6B000A; Mon, 29 Apr 2019 15:43:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C72E6B000C; Mon, 29 Apr 2019 15:43:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 567786B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:43:31 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v7so13833394wrq.10
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:43:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9Q4kPSWDfko4K55jmv4VLwHX5C3YEWUBtQVYLgp5/2o=;
        b=d90a5LqMpqrWIvPeOTif0Kw5wNSY9GsY4azR20Iv5mp4QE+mn7IJT4F0RbK5RskCIM
         ahabavdB+ii2LEzVZxRjAsdl8mq1eXjLCw0L3/DOFZ/xdld9CUOM7PrkHrzbkF294Zoq
         6i2ObDG1kTko3KqkGasje1BGEGyHWGU2F4pD4d4UzEf3ZT95k/F13LUzYRWT9I3a5QyJ
         2aIdEboqCJ0k0BCQZ9+EmSWZIChLIQtIpQMdQdSHgy59e8JoS5aVXrmXIBBL7PCDS5x6
         w/MotR2l7A8pieAottAigqFp9G13SlPliDzE7hr/SymQOtU4TcuYXrVJ0Nf2+WjQqawk
         tMHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWUlMiVzwUiAz9VV7PvlfsPqGqHeUslszSoABiujfBBSb61l3FL
	wNY6tGD/QjyxqQcPIJMjr2BYVcDyjFxducHLCJpBLasykOfuX1xv4y4Qt/LgDpXXnlkXAGs+prH
	Spg+amdFbUGUpm8dCf1Z7XK8woDmH2lXoh9uO/YXbzKM6upTdlwcHT02gIThmbtp9ng==
X-Received: by 2002:a5d:5308:: with SMTP id e8mr11870678wrv.126.1556567010962;
        Mon, 29 Apr 2019 12:43:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl1UIqOmK33bGocvV1Ikf+yWJ1pzKeru74jd0StMls3V7BG/rMMtt0esGJ5cXUT6pAPcJE
X-Received: by 2002:a5d:5308:: with SMTP id e8mr11870653wrv.126.1556567010346;
        Mon, 29 Apr 2019 12:43:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556567010; cv=none;
        d=google.com; s=arc-20160816;
        b=Vxsp7+fWMAeVbL9VRaWRR66mUNHa/JdIxwtKRWz3HhwGrX/P1nre2g+YBpVocAqgjS
         ouR9dqxycmzB82LPDjNyKRUehFwGvf45qWi78eYO/Nlj24v5a7AbjUG1/RBiWVKBHHoe
         zkDA3F6Wt5oP35cLxaBzDJs8qM6p+HLpuoRj/LlaXKDKUp8x7XdXdSZ1GXgXtSkSwMBT
         8ttOxIiJOgcx6iUJL6VruzpIb5w82sxUZeN45wQl/RdicAh0RpNtRSftiMDGI99fZvDo
         wDJAqxbw/KWdGv4Pp3N5xvqdxauCHDB9zjJ9zCWD8RQcXuuvExYDtnL1bLRQtUjGJf3b
         EQ+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9Q4kPSWDfko4K55jmv4VLwHX5C3YEWUBtQVYLgp5/2o=;
        b=bss2kQWBWAx4/k4lxsQJyQtoXyAGY+KjvY41X8mkGz4cXMfPPrAQrIoExeg8avjaqW
         /4mThY7ZKVSEjcEvGtoV2VWnCe5/02tp7zStokNLsPKfCD7xyGTa388U+OvhnRF7samv
         eDugEDXmJYxhS9hXiuFsVfPNVme/ganbYXqXs7SxtIbiZ6UlY9QRCbqcLTFa/Zf17q79
         hOBrmzvXiI7yO+D3jXOjebV13xgw9qMSZ2SPkU1gnq/FksyijnRHWIjAQAlFQk6MqTqc
         TSlvrApr85SKP6TRdSwgUtqKd70lfwFZwdGNiH4vyV/EE/XuWELnwFvItSlQipgBtro/
         rq0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b12si1112243wro.159.2019.04.29.12.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:43:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id C021568AFE; Mon, 29 Apr 2019 21:43:14 +0200 (CEST)
Date: Mon, 29 Apr 2019 21:43:14 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v6 2/4] iomap: Fix use-after-free error in page_done
 callback
Message-ID: <20190429194314.GB6138@lst.de>
References: <20190429163239.4874-1-agruenba@redhat.com> <20190429163239.4874-2-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429163239.4874-2-agruenba@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Or we could merge the dropping of the __generic_write_end return
value into this one if you prefer.

Either way:

Reviewed-by: Christoph Hellwig <hch@lst.de>

