Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82473C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 17:11:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 237BC21734
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 17:11:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="BtXkSUiE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 237BC21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0086B0006; Fri, 26 Jul 2019 13:11:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6510C8E0003; Fri, 26 Jul 2019 13:11:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53EEF8E0002; Fri, 26 Jul 2019 13:11:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E61F6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 13:11:55 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id w6so41228457ybe.23
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 10:11:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=esO7QnCCyx9dzKTMgBFciVXyQ2aruZtdaUPoDfDZZgU=;
        b=gmVctLJ1hUMvs7bX+pOVjZRygCa0y6HKqfpAaOaCdMsberd6DR3i7v6WH5etgNXqVU
         F5hqEOrKbGsYKjymY4bYDfParDk1j7lCocrbbYuXDuXGBodZZKGuHYPNtPN21d13t9f1
         JFqe+EzZBoqKihZ5rzUMEV+/xzmkrThvqKzrkYN6ZV+NDk+JUIwBf+7H+ImQ4Lgd252i
         2C2Mqs7E19YhKENo13lNlnNISaS1FqJHDvuA7SdpMBHMUn5FaOH15fNeDQ83Uk1+0NJi
         +5WdXPIwPsPi3tkkXaTf9jPgzxxng/Z/8gWilGTrC0Ut1mW29LpWBMR48ZPhOIC6kis7
         AyGA==
X-Gm-Message-State: APjAAAW6QmZsbAq0ipt8iGZz0L7ccOEUD826TmESPsjFv+l3luKypQYc
	/eoCUkLK+umcn+oAHb+9tS+7fklT6ubsoi19Nm0TFRKf+ylvIw/NgElOIjLHqtIqhFNkVPySy//
	O7g/DKHFohlc0VBqYXOPwmESjR+pKtbBkI5flTmfG8YQWlA5la2cx0RvWzfFQBGWdaQ==
X-Received: by 2002:a25:4107:: with SMTP id o7mr6035040yba.128.1564161114647;
        Fri, 26 Jul 2019 10:11:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyibpz4uRKFYtG0EP9hmeERw1Qj1mVmmCUGxnsfkRVsTR30tiJlCRbJrZNJ0n7uDpdtL0vH
X-Received: by 2002:a25:4107:: with SMTP id o7mr6034993yba.128.1564161113973;
        Fri, 26 Jul 2019 10:11:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564161113; cv=none;
        d=google.com; s=arc-20160816;
        b=oW8O0u4Nu0eztyYIJ7fofcpnCeTX2qVAK4g7Wlinb8DIi0E574iauUorlCfIp0ZeIh
         BUulwVlz/HJEyjVu/viyxbkewwiBHd2KiJPUBkowwVU2YkpqLqbBdvHyn8nebLaO56pH
         b1qL/F05yEshZhi+UtK+/bk0gu1hEW3nkSbatwAjWZ0d3E6H20TnIPtPoXyrwJub57gh
         06Iua5aZ3clZxK6SgB5FB7tzwOMeAokMx8nym0E+gXpE/F6x3SywOeF4t0ZC1y2ESfan
         jUB35Rt+/T48NTmEOh+GXdQNlzIvSGZc1yXHXXZsTtKqT51JJstp7NmJACTEvZpy1ESC
         7ZWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=esO7QnCCyx9dzKTMgBFciVXyQ2aruZtdaUPoDfDZZgU=;
        b=mvr6vdKUQmyLajD0jdeDUO7/q+5EneW3dnFMsuw9LCmKlTkmAw99LgoJNpY+nNzazA
         Nv37vESTXdPJnE7yAa9CRLTMC2+lCn56zCDfKGmh2z7s5f1vOMG6aLQkEXF7xkT3YisC
         MLOUWLp8emN/3f1TPdF+SoHff0SxvVvkKaSxrBIbQhr3O2ukh1Yw5Bkep372oORSx/z7
         fG4OVfB4MYHU3haXeYus9BNs+NRNqubWevRaXKQx2sYgxXjASlcw57xGSubXHSUapc1o
         XPNp4f+LgrCy30u0m1NLyZcWkkqrNPV2JD2hLJ2a2ayzS/Y1fvvxEYx41lBZKKIYlCZF
         UQlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BtXkSUiE;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id l143si19063338ywc.208.2019.07.26.10.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 10:11:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BtXkSUiE;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3b34610000>; Fri, 26 Jul 2019 10:12:01 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 26 Jul 2019 10:11:53 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 26 Jul 2019 10:11:53 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 17:11:48 +0000
Subject: Re: [PATCH v2 2/7] mm/hmm: a few more C style and comment clean ups
To: Christoph Hellwig <hch@lst.de>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<amd-gfx@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<nouveau@lists.freedesktop.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
 <20190726005650.2566-3-rcampbell@nvidia.com> <20190726062320.GA22881@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <6673dc71-f43e-849f-ca36-0b20805fc092@nvidia.com>
Date: Fri, 26 Jul 2019 10:11:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190726062320.GA22881@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564161121; bh=esO7QnCCyx9dzKTMgBFciVXyQ2aruZtdaUPoDfDZZgU=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=BtXkSUiESCykynn98aAUZOYyg4yz7jKnWyWlQeuTkJgRs1pzxbnG+tdWelFiuNWFf
	 lk2A6TLLDs6cQLe2Yo2AGejt/oTzYMtS1amgKmn2dm5v84UdJRMTYaGngk6xAfFfNb
	 p99GEAtPQKu0WpF74vtOAbWCO1P3EV8HcGsPjmb/CtOUwIfsJf4d4RzpBS0UZFOFl5
	 mKy6fFTJpky1hLxVBJ8kIaj3ucax+hLNkEj3Rb1EYWFnVqCmhNJAyxMjR01QHESrZT
	 ZRtQfwyfeh21KLwAKZ3N0lRnAXuC9Yp0RdEq+oNcbACTXWG+Ly+6gcvZF0sXLDUj4M
	 vgXH0/SGBnYgA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/25/19 11:23 PM, Christoph Hellwig wrote:
> Note: it seems like you've only CCed me on patches 2-7, but not on the
> cover letter and patch 1.  I'll try to find them later, but to make Ccs
> useful they should normally cover the whole series.
> 
> Otherwise this looks fine to me:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 

Thanks for the review and sorry about the oversight on CCs.

