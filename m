Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87948C46470
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:22:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 577E72070D
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:22:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 577E72070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7AFC6B0003; Mon, 13 May 2019 15:22:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2C596B0006; Mon, 13 May 2019 15:22:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D199A6B0007; Mon, 13 May 2019 15:22:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1F486B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:22:37 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id f196so436145itf.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 12:22:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :references:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=gYQxJdvt9hloW4dlwqQ9q53mGaWVyX9Ony+mkRpnZrg=;
        b=Szdha1dDDnrLsbtq0FMg9VNQxGhHY/0X09cfW5q212zIoBb5ozeS1he/9rqb+La/jc
         6vbVeYqU779tkDY4WcCwiQDmi9r3O7Tg7ZJE+RtKbv+Qw6bFiKNaF7OWZRTQwYhmb5aB
         C0bYqnTWJKhHQfHkF1E3LTXqkdxoxyc9DBhk88slxpUV0romw5A+cICF0U5juLkV7il2
         JcVLO+U/zO+Ia15Dv9qUE4BenM1/E5aFS86eKLFq+40mckdSMICodyHSfpzQX+vgYRSm
         gK0psHXtmxBe4wwm5PiJaUeaYp9aRafNV+Vy+hmvxREVJlqmd/bdI0oXQ0XiWCwLHJ4C
         Xp+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAXH6d6vpo3YFb7DXiiMEzNpyohHfPWRIPubQ/sX7u3/lpdrPd8U
	6t+Dc5dGVpDcZ0i8LkR6vY0Ciy8mYCr2qZezf9SpeTx1bQDp0N31MVj5OI8rGKLyclnNrO1Ton9
	bqsrQlQemPQijdtO85N+4MUT9qHhJixymK6X4B4LBaqfkY7rcedVrwhYKgdDwuEOyKA==
X-Received: by 2002:a24:1f50:: with SMTP id d77mr574450itd.25.1557775357467;
        Mon, 13 May 2019 12:22:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOQbfvgKtg8xV47TbaEnI5tCniyTvCE17usMiQh4HcIieokKLJkmIemTWj8JnorRfX8Ap9
X-Received: by 2002:a24:1f50:: with SMTP id d77mr574421itd.25.1557775356764;
        Mon, 13 May 2019 12:22:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557775356; cv=none;
        d=google.com; s=arc-20160816;
        b=kIDmP9zApgHiCz0qCH6Wzc/LS5bmRCkzTvUdiVBPfNOarKzPl0FP5Reu0aWhYIyEpn
         XhJ1aWdYiKcmvJDUTIO59utM4HP0L5iBqyAY3iEQfR5DMV80K/aogMYs2P11E2C8Vemm
         rMMTK/+hEhPg1/z13NafaHv8okVJhDg2BBv0LxKl0WIIadWSzx2FrFPQsLqqA0Sw77LT
         QLchTFO8suP5ENOeLwMlmbaQl31Rt4OCgDYqwypZpioifBPp+x4NiTvTktZD+g/obU6g
         4WTy0FBVNer+YLaRHvaL/+ZueCWOgPXuisJ0JqouwGZ+5fwvEHXFFO923qiIFkKBeKNb
         qOjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:references:cc:to:from;
        bh=gYQxJdvt9hloW4dlwqQ9q53mGaWVyX9Ony+mkRpnZrg=;
        b=si2wPXApshPIR2T4ofxdN9bHdFDbOYy+VLei2XAWZuz8Rmlj6yvF4hpPi1yF6P2gc8
         hSBeEKU313RrkUiFB0cWtP5NOM+XVwiYpYmhZf8UASlQzWHKziGV4tkwWZYhHZkXXG1t
         tGDD+gagD9ZUMQ9Ea1if9bE+IM4G29N0p/LUZo3+1CC83lb+2HhJjg1gWKKdpBoV3tBw
         mW9dzmAoaPhsD0/kS05+RR86eTpD/A8lA+Pih5QYE6TLU1e6222CBNgb97l6iYNZbfq2
         Q+v9ttO2NYQvwqdkTr/fFqh6ij67/o6LroTVsY5a4EzVHky/Jm2/s+bFgz4NflKwwQaC
         lwUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id s140si7776662ios.31.2019.05.13.12.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 12:22:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hQGWw-0001t0-G1; Mon, 13 May 2019 13:22:35 -0600
From: Logan Gunthorpe <logang@deltatee.com>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Ira Weiny <ira.weiny@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
Message-ID: <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
Date: Mon, 13 May 2019 13:22:30 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
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



On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
> 
> 
> On 2019-05-07 5:55 p.m., Dan Williams wrote:
>> Changes since v1 [1]:
>> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
>>
>> - Refresh the p2pdma patch headers to match the format of other p2pdma
>>    patches (Bjorn)
>>
>> - Collect Ira's reviewed-by
>>
>> [1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/
> 
> This series looks good to me:
> 
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> 
> However, I haven't tested it yet but I intend to later this week.

I've tested libnvdimm-pending which includes this series on my setup and
everything works great.

Thanks,

Logan

