Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A86C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:23:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79B8920850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:23:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="CCd8e2Op"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79B8920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 133196B026A; Thu, 13 Jun 2019 21:23:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5736B026B; Thu, 13 Jun 2019 21:23:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEEF66B026C; Thu, 13 Jun 2019 21:23:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFD2B6B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:23:09 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v205so872109ywb.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:23:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=NWiGQvc0UaQg06vGlx/KBoyQY7FTb90HKZp/7cWu1+4=;
        b=bErcFmXe5nawIqtfKYQRPit811RmRTsgUpXGTp8071ImTalPyU9cgD+emGfF3TYNc3
         r0O3G96uwR7gyVcU4AgmKagH5cV+F1dxh9Uqsskz81cx3hz6QoKGbbJJSM1XvbNitguD
         iH3YYQIxNpG+5aQLIIyzepWt6NeV0htv6QTXZDMjTpBmpO/+ncLplnX9B5XdR00kV0EH
         oi5KF2/0XhzToqKUOaZX0h7EWckP4Ltj2CByH6qKyDcqkAeqC1GjiL0IrswEIyg2q51e
         KJX3cywYmEL8x7YI6itFbjVXhmEYCaC/hszNmzx23EXp4wXaNbb8JjEuUGX8Edc6IHI7
         damw==
X-Gm-Message-State: APjAAAVuzp8VFQikkbcuwyOvFqgL+nSU5TT5elSGsE1DUJli6BI7FnBC
	ftD6p/PmCl/v6lvGSa7a11hRCfCS2YbYvRyh/ggL4BLFE1XnCdjQ5IZnN5UYMa66JVhbOEzB5SS
	Qg2YiImZR6N23s7RbO+Hn13TtJ6bMfogR1AdcTVKOgzI0zrhDpB40LopSJ3sIS+o7Vw==
X-Received: by 2002:a25:1454:: with SMTP id 81mr6175357ybu.96.1560475389597;
        Thu, 13 Jun 2019 18:23:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUFRpJ9dHUbFmUMf8GX0OUlkkHkql6/2fu+fSg5fG+JDfjd/FGoEZyU5ida66ZGFIeDbWp
X-Received: by 2002:a25:1454:: with SMTP id 81mr6175349ybu.96.1560475389044;
        Thu, 13 Jun 2019 18:23:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560475389; cv=none;
        d=google.com; s=arc-20160816;
        b=foK/gYBUCtuoTAozr9kcVyqp8YJIvPgXjvjFtbh4h5SuJsUVtqTJMCrYB4qeWJODpy
         3bnDS8gO2KjpF50ygJ5vWmn5PMQLiqZoBCVrAEaJgSffWgN5jofu3OD0oCzpEP5cmghk
         NI6QzL83FNcIyTY/Mv4vw836O1hC0E3bDkYfHD6HIl6Vvxv4guFm4Mjq3oB/igSFiA2A
         dICYDngHMIJTCLiNCMGYXNqSrJhEZHCCkuHBBOwllfZHhqR/dG0Vm52sRgyiGkEHc/tU
         DSCx95sFEyt853g2kTlOzx3jZuVkzKwAonOU88eDpB/RStBBHpiwDJlbn1d1gIFyNQIm
         jMrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=NWiGQvc0UaQg06vGlx/KBoyQY7FTb90HKZp/7cWu1+4=;
        b=AHPpuok/DQLhGJy41yEuMsNgDP5Rih2XbD+Qi0M9ULPn5NDyuWS7b/ADhgRrANsh86
         Or4cUxhrt/CadU/w477MWAufB5sKZCWAm5YSWPPZ43nYpSgpPF0Hcq28zUJi0eFDO3TY
         XoVzWsUeDnU7uO/fmbTRJLPxaGJZL2z8NdzJhD6puRfjMbG0hvkXyYKyhKP5l41GHf4t
         kFE5N9tt1MvKjjjuuWqIkvcR//L40Z4IKzXh7hxBSiklpYp+FhpLgkxeNqqwSgFFxoPd
         KCF4T6ahUYJ51RPS2AAu4eUm2tLh6/VLODwInEHpwtQQ1Gkz8eFFW/QtUp+2k5YJl2R3
         pvfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CCd8e2Op;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id w8si433824ybo.234.2019.06.13.18.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 18:23:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CCd8e2Op;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02f6fc0000>; Thu, 13 Jun 2019 18:23:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 18:23:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 18:23:08 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 01:23:04 +0000
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
To: Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@mellanox.com>
CC: Ralph Campbell <rcampbell@nvidia.com>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, Christoph Hellwig <hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com>
 <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com>
Date: Thu, 13 Jun 2019 18:23:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560475388; bh=NWiGQvc0UaQg06vGlx/KBoyQY7FTb90HKZp/7cWu1+4=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=CCd8e2OpQNYk9MLkQj2SISKb1f8rHEt8owfBUnfdQ/EbQaEHFbssnQujsTCvu1hg/
	 mR8Y3/sQ0FeoXBKw8x7EwSNeP0JirtlvLprjUK1BAmudORUfLC87dyxEeAk19INas5
	 NI29MBs4mO8FUO+2r1avdCcLUMWD+OBag9RCJIoLc2O2dHRfWViTRDAYcfn3m6Wrf6
	 udfy6sC0OFEAlHI5edqKIVUfELxR84G7Dkf+roQu6aKqp3E13WZ1IqDdG/Lffgeh/e
	 nogIq4wl7uO95KxuzvD0ijZERk5Gr6SxTkWBIiWMnMYA0zmWut5Pf3opqWtrNeceNW
	 Ua0w/eL4F+pAQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 5:43 PM, Ira Weiny wrote:
> On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
>> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
>>>
...
>> Hum, so the only thing this config does is short circuit here:
>>
>> static inline bool is_device_public_page(const struct page *page)
>> {
>>         return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
>>                 IS_ENABLED(CONFIG_DEVICE_PUBLIC) &&
>>                 is_zone_device_page(page) &&
>>                 page->pgmap->type == MEMORY_DEVICE_PUBLIC;
>> }
>>
>> Which is called all over the place.. 
> 
> <sigh>  yes but the earlier patch:
> 
> [PATCH 03/22] mm: remove hmm_devmem_add_resource
> 
> Removes the only place type is set to MEMORY_DEVICE_PUBLIC.
> 
> So I think it is ok.  Frankly I was wondering if we should remove the public
> type altogether but conceptually it seems ok.  But I don't see any users of it
> so...  should we get rid of it in the code rather than turning the config off?
> 
> Ira

That seems reasonable. I recall that the hope was for those IBM Power 9
systems to use _PUBLIC, as they have hardware-based coherent device (GPU)
memory, and so the memory really is visible to the CPU. And the IBM team
was thinking of taking advantage of it. But I haven't seen anything on
that front for a while.

So maybe it will get re-added as part of a future patchset to use that
kind of memory, but yes, we should not hesitate to clean house at this
point, and delete unused code.


thanks,
-- 
John Hubbard
NVIDIA

> 
>>
>> So, yes, we really don't want any distro or something to turn this on
>> until it has a use.
>>
>> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
>>
>> Jason
>> _______________________________________________
>> Linux-nvdimm mailing list
>> Linux-nvdimm@lists.01.org
>> https://lists.01.org/mailman/listinfo/linux-nvdimm

