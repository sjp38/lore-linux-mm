Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 176CAC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:46:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C49552082E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:46:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ixXygCg2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C49552082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51DF08E006A; Mon,  4 Feb 2019 18:46:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CAFB8E001C; Mon,  4 Feb 2019 18:46:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BB1C8E006A; Mon,  4 Feb 2019 18:46:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC728E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 18:46:13 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so1393900ywc.6
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 15:46:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=5NsYQ/4HOoDcTzNeNFjJpj3wF25bDpqGw7ZVtFfjPqo=;
        b=dC7/41tGtM0776rM52Zp8apwkr9pEXIzD1mxmZBLofEIZJhnKtqDcW9PXHvjc3RGNj
         LkMcwWucQRa2MBCd4XOl5p8Uqr0Tzy7WvuxX4T0fIddkeASfno6MW9MrK6/mK9VpfoU9
         Px3I1nKP+pcK5+yrHKQOLdVD80DX5mwsyhk45Lncy9jKJEGDIzNVJk1sogPrd1mmoiCD
         JI2hFIzGg9p4BZyEZXwFrF09B2Rz/0dKbOXFLPmqs8Yy059BuBQ6s3nwT8mimCzSL1cb
         F/SAh2cKIrL0RwO4lXd5NllpRg9pX3Q68qUFkq2YfhBmBJae0/SceV0DTrFzAjpSnFhm
         +REw==
X-Gm-Message-State: AHQUAubW8qKMGhJ4QjJvYvUfsyZvN1JubqGMROKglhKvU3Em3F3iSqfS
	GoKxz9IxEnYupRFogTENQYL+EGzWir3GrGt6pfj8HR0N7db+ylwCxxCVEIeR/OwPjYSRJp6Vx0t
	LRAQvKn9P8rxH44LR1posStXjuIwJxbDiQuITj36/xJwosmCMjpk+3nU7B/eJ4pkDzQ==
X-Received: by 2002:a5b:712:: with SMTP id g18mr1593712ybq.171.1549323972745;
        Mon, 04 Feb 2019 15:46:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqYWLFYWPqfXrYOeOg2HCE7uiVUzsnfl87E5EUcyW8NiXfPLZWfbyk36ptdOan4IJnYUCz
X-Received: by 2002:a5b:712:: with SMTP id g18mr1593685ybq.171.1549323972037;
        Mon, 04 Feb 2019 15:46:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549323972; cv=none;
        d=google.com; s=arc-20160816;
        b=qW4ecPOXVUfMxL4hRrqVQRD8EM+xt13D9Pe/BF4WzcthhFhYP2zS4/DBAJ5vNzYbtw
         /Uo86OYkzGX+L7Jz7/OBEV/sUzj1qciqQWUVvqk9JzJrrzSectdgKHZq6AVX2umz1Sct
         FPz6E2w2Y1a1CzplroMczFqBuh1SFvDEAbPcjRjWbS2nkhuEgf3JXB4Wttw5SyNLycQX
         zmwLriivbmKqrFQmfelYgBAOGIVWzUJZODNGI8CFcJ+GCc7tcs5gByX7uAh+QI01iCtk
         fgz/mX1ZJPtHYlhc0QG+4DCNHGoFZLxOoz0MaFRBXCYWDrd1wbQSYDvq9o3fIc5SMDo5
         2BYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=5NsYQ/4HOoDcTzNeNFjJpj3wF25bDpqGw7ZVtFfjPqo=;
        b=KCV0GF3BP2IxVWWIJCIf9nFUB/kO8P2teg+Zx/qS26duz50zgKhiI+6krke4UTcSH+
         TzSg2Wc6qjr+iDgDU5dYxvjuPyiEj8s3eoEXemH0YjC9Pxfy/qaHo8XXsMl+Tb2vC6/Z
         DFnMhlGtJ6YPWSlB7MJKqNeMZAR/oPy18A8u/v+Hl6lxq15j782KFFqmF4Jr3gWtiZ61
         ipiUMlrcka4xmWQd286QgSm3OUwG4UmiCPRUL88uAKKPF9zxvgaHmLZtQPSVi64YTqx5
         RwHFsHJBFRR/9/gNhO6Y0vD6qzjW4D5DzDjVKx5RLnQBASaiRLvKalf+TE4gP6JIsRMJ
         yxkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ixXygCg2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 81si961876ybb.155.2019.02.04.15.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 15:46:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ixXygCg2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c58cec60000>; Mon, 04 Feb 2019 15:46:14 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 04 Feb 2019 15:46:11 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 04 Feb 2019 15:46:11 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 4 Feb
 2019 23:46:10 +0000
Subject: Re: [LSF/MM TOPIC] get_user_pages() pins in file mappings
To: Jan Kara <jack@suse.cz>, <lsf-pc@lists.linux-foundation.org>
CC: <linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>, Dan Williams
	<dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>
References: <20190124090400.GE12184@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <a0d37cc9-2d44-ac58-0dc0-c245a55082c3@nvidia.com>
Date: Mon, 4 Feb 2019 15:46:10 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190124090400.GE12184@quack2.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549323974; bh=5NsYQ/4HOoDcTzNeNFjJpj3wF25bDpqGw7ZVtFfjPqo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ixXygCg275qslNPJcHrav0jWtEpSE8OarAdaOFR5GZ239yRNLw1/3gPVP4h7rsUw8
	 Yd8ivw8A6E/n6ncupG4PdenV62MOKNmyWaPnQ5KCrePFLA4JzOs9usNP49fTToymTY
	 FlrbG1vfsMRk88TROKw+p4+l8xw2AltyIbCqLT4wM7k1jG4y34DOe5/4e5vC9BaKW5
	 ZsdMUxPJefxvEZB1gWDLShOsRE2QzsSNzcFFcWIvonCRJBABk2rTD6tLiwPTkw/xHz
	 d2iUqRoYXszNhSRLDXeD+Lh8tbUQLYLQ9mvECKKF969TBAYfoiEE10DR249RQzTLtH
	 L6NQ6ONzriVJQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/24/19 1:04 AM, Jan Kara wrote:

> In particular we hope to have reasonably robust mechanism of identifying
> pages pinned by GUP (patches will be posted soon) - I'd like to run that by
> MM folks (unless discussion happens on mailing lists before LSF/MM). We
> also have ideas how filesystems should react to pinned page in their
> writepages methods - there will be some changes needed in some filesystems
> to bounce the page if they need stable page contents. So I'd like to
> explain why we chose to do bouncing to fs people (i.e., why we cannot just
> wait, skip the page, do something else etc.) to save us from the same
> discussion with each fs separately and also hash out what the API for
> filesystems to do this should look like. Finally we plan to keep pinned
> page permanently dirty - again something I'd like to explain why we do this
> and gather input from other people.

Hi Jan,

Say, I was just talking through this point with someone on our driver team, 
and suddenly realized that I'm now slightly confused on one point. If we end
up keeping the gup-pinned pages effectively permanently dirty while pinned,
then maybe the call sites no longer need to specify "dirty" (or not) when
they call put_user_page*()?

In other words, the RFC [1] has this API:

    void put_user_page(struct page *page);
    void put_user_pages_dirty(struct page **pages, unsigned long npages);
    void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
    void put_user_pages(struct page **pages, unsigned long npages);

But maybe we only really need this:

    void put_user_page(struct page *page);
    void put_user_pages(struct page **pages, unsigned long npages);

?

[1] https://lkml.kernel.org/r/20190204052135.25784-1-jhubbard@nvidia.com

thanks,
-- 
John Hubbard
NVIDIA

