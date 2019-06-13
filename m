Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A35FBC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:12:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7703820B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:12:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7703820B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 107F76B000A; Thu, 13 Jun 2019 16:12:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 092666B000C; Thu, 13 Jun 2019 16:12:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9B4E8E0002; Thu, 13 Jun 2019 16:12:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id C80646B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:12:32 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id m1so21128iop.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:12:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=wGiaK/n58dyruTpLkbztEBq0XBXuO4QUJ9Ych5Hr3V8=;
        b=hjzzizxpd3SVkfEdv0j0YKCNFdZkrkvWTBLw73lAUhTXmqj8tdnhhP65vurlllyqvF
         YeRyNgEnviIcpUV0sEBDzasXHTs/OlcFsWcWjxRU/mycMre7AE0v5Pj2zANQnduRKUHK
         yEU92NRT7KsaMWj0DvO6jS6reLdAfewpQ9eq1Pq5+HU0874OnAPqJSfhVzX54X+hUNy7
         KMgAt4fx+U+oX2v94NOq2EW0qGQKRJAUDi1cRg8ytOtWRUoR3DrRNKUY9dCEoQakU1uB
         kYvCjqoO+82Bwdj2fk3DsNo8V7610PePuB6u54/HN1BPeOroJFkTg/ldWwCtsBjy7Qor
         TJ3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAWwvKWu+Rcid81aXmh7X37LNwQEhjUfNExy347LlqkhY6bpO9wQ
	iP+gfeGOe1d6sPtkytSi13f32VS1lTMUtK8jmpqCKDLDsF+JM5ppg/O74GsATS74M0NBi+/jzG9
	GFFAT05Qc28kkg3SUztdCX2vHGslovzg1mHNditvhPT/u1HmIHkU7yXwxlFoHd1y9FQ==
X-Received: by 2002:a5e:8505:: with SMTP id i5mr4585682ioj.101.1560456752510;
        Thu, 13 Jun 2019 13:12:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM4J8pb9pYkeLwgwX12UYu5Zhj9/SeSv+bG7wyxSWGIhuNPnbXKgbNGiVVwoAXSvKsFaJt
X-Received: by 2002:a5e:8505:: with SMTP id i5mr4585627ioj.101.1560456751891;
        Thu, 13 Jun 2019 13:12:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456751; cv=none;
        d=google.com; s=arc-20160816;
        b=D0F8b1IT3yGGC13BZ7jCO5XHr50VptRE99QIpWSUpJULiLzOZ+ZOTkAnLqpKNjzlK6
         onAsbKtCl35mvKTdoS/EbxnoWXkISbaBBSeQBSQLc2OXeIu2KD1M/bSKxke1IGUDcay3
         nK6TCvcMntCghY9UfcNlZx0uGczbAMPZPgt3kOHeGAhomgSzqfuUVzHj+R9UAGXe8+KL
         /KZ/O/De97a4TRcLgWaIiGZheDmZ2j94JcSg4qpe08KribkLbM7j9jRX5gfp/6483s8A
         LsY5hCo1BDshcYAoLVc9+31a5qknWBOyMg1D73QLePFcei6MeFgbylpDDTgeZRS9lBWB
         jBXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=wGiaK/n58dyruTpLkbztEBq0XBXuO4QUJ9Ych5Hr3V8=;
        b=pYgnWqTifRBqJDwQBYdsK0YA0/R+e/OXIg6PHhoJGTN/UaLWVBaN8dqGbI0bSjhJyz
         LrOi8Zk+YXCpJlVma3AqgyZHjazGbjXzRGH17xZoGF6r70gkeexYiHZagCmB/0t9pcYy
         WbbKfmK0pSjG4qhIqpmI1Ws5bkDTRN7AIb3Cfk9Zq9nE8mfL+xzVTiLKkA9BkCeaeFSu
         EcnhozvOkWGf9Mca7K+11ms8udWTiIwixJDvvYLAv968twduWHFzWVCrwAGQ3S4tPeyB
         aD9LpZb0qeOAhUIJ7awz9BtZZG3fb7gZlfknlwHy6quFN9o+DIYDu95S3+PXf25ys67A
         KoqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id g11si606797ioc.101.2019.06.13.13.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 13:12:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.132])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hbW5G-00040b-8N; Thu, 13 Jun 2019 14:12:31 -0600
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, nouveau@lists.freedesktop.org
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-9-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <d9e24f8e-986d-e7b8-cf1d-9344ba51719e@deltatee.com>
Date: Thu, 13 Jun 2019 14:12:26 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-9-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, dan.j.williams@intel.com, hch@lst.de
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 08/22] memremap: pass a struct dev_pagemap to ->kill
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-13 3:43 a.m., Christoph Hellwig wrote:
> Passing the actual typed structure leads to more understandable code
> vs the actual references.

Ha, ok, I originally suggested this to Dan when he introduced the
callback[1].

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Logan

[1]
https://lore.kernel.org/lkml/8f0cae82-130f-8a64-cfbd-fda5fd76bb79@deltatee.com/T/#u

