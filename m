Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B3F0C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 17:05:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66AA021530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 17:05:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66AA021530
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D167F6B0273; Wed,  8 May 2019 13:05:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC73F6B0276; Wed,  8 May 2019 13:05:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB4436B0277; Wed,  8 May 2019 13:05:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1096B0273
	for <linux-mm@kvack.org>; Wed,  8 May 2019 13:05:53 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id m6so2712399ita.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 10:05:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=ZavAmhO0WoM8wXALZROGI0KXTFgW/iJhFYjlia+Fu0k=;
        b=mAKkxZKhi97OEA1BgX3F0LIt15mLJbYrWEZ9O3h1GHEYF6azWy2wDWZbqq41AmXMPN
         H/fAImfWSBde9Qe61LVklkdtjpEYDIOAQuNNL5Ys4AR3g35m/k9W0YFYoF4DSnbctifY
         PPgFil/W6waUA4cuu/LqSF669i/YrxtdSgBJczPIuECvGBss3Oyol0DMqVeE7pagTivB
         i4OEuZbb+Tkf+CKAKfMzsA7/tfbAdqitD63/qFBJZgAV07HcH4dG8+aIR5PdckjvV6rB
         p4KiIgD0mo5qIqxigFpF41UdrSqob2L2PdDNu00n+TahY4v8hNPPfKD0LfLMVek3TJyG
         2zUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAXqtiHqUFjYFqsIugFITEwloeBafC7z77SL3PkrXDL6qProhpkB
	LVhINsb53sxnjVF4lFCDT8VC0bmitqqivQRBBFDgFragVUxSnUZTvP2KoZ59s8ACKIVlwq2/c/B
	2h2/nwfEhDB7OFeIGDx9MLkDRrKo0CNaCTPFEIqE1GixNglf0rbkluvbbXkmPXv0t0A==
X-Received: by 2002:a6b:7d08:: with SMTP id c8mr16852553ioq.259.1557335153431;
        Wed, 08 May 2019 10:05:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqBE45k6KzJVmo2lQbvGvcof0ePvNNX18F1qejiGqF+zgluZKRTwIOqYlPk4LyfJT6f2rz
X-Received: by 2002:a6b:7d08:: with SMTP id c8mr16852508ioq.259.1557335152737;
        Wed, 08 May 2019 10:05:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557335152; cv=none;
        d=google.com; s=arc-20160816;
        b=WnlqNCFjLTLLYM3XkLSAxI1K1UUjsTd73Wf5ozpNpE/OuXyTdKxxDy9vNZxSLlVv4I
         RC6YENM5hh/dDHmTCC/meZR3uFExHw8aUmvW+R7q6CfAUKEI0mHyjGXJGcQLoJnxGDZm
         uWG/4qZff9XjM52IBbkzCQfZRelIWfYeyqClY7NhyMlPlYto7TIIQ9ZuMciTXRyxp7l1
         79eV7RJ7LGqn8VmfZ3l3zJ+3JF7UarPLc8kEXvbgkSNSEMgga60NeKg/rauhJ228qt/J
         y8wGKD3ejGOlZDRFsACga9l0u7sJaEwIzg6EfgtAP8+rxjOu1rksb1rC5Gerrgjssls1
         a3gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=ZavAmhO0WoM8wXALZROGI0KXTFgW/iJhFYjlia+Fu0k=;
        b=zLtdq7EcJhbQQJf+hkZrYop9zgqbJFAAHpEi37SYTg74GPfh7t08WQ+ADtwJ1sADBo
         Cq7E5CdEZjgobAce51+jNjdF5X5s8CZdoZ7VngE9IxP1s0754m+doBLRSlnRXizEf//+
         wc8xaUvcRKnGG1C72l6RT4v92fmnDmY+gxBXZAuWG9mkbo/RarePXy7yKiaLyqFfRBjg
         xqsFg8MjMSlfUiG2594/y3lO2WJLBsG7uZTP7QctQS9WpBNcGCcGxFY7FjrklsE8KVFH
         PyolUZwORQWaYqccnpOYUuiFP+cqeOyAiJUAwdwEQDzVkPqCs50SYjT53ZbykPj0GbC6
         60aw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id v10si12214252ioq.43.2019.05.08.10.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 08 May 2019 10:05:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.141])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hOQ0s-0001ya-OA; Wed, 08 May 2019 11:05:51 -0600
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Ira Weiny <ira.weiny@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
Date: Wed, 8 May 2019 11:05:46 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, rafael@kernel.org, gregkh@linuxfoundation.org, jglisse@redhat.com, hch@lst.de, bhelgaas@google.com, ira.weiny@intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-05-07 5:55 p.m., Dan Williams wrote:
> Changes since v1 [1]:
> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
> 
> - Refresh the p2pdma patch headers to match the format of other p2pdma
>    patches (Bjorn)
> 
> - Collect Ira's reviewed-by
> 
> [1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/

This series looks good to me:

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

However, I haven't tested it yet but I intend to later this week.

Thanks,

Logan

