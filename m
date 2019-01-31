Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B045C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:08:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9A72218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:08:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9A72218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sntech.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 677BB8E0004; Thu, 31 Jan 2019 07:08:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6270B8E0001; Thu, 31 Jan 2019 07:08:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53D568E0004; Thu, 31 Jan 2019 07:08:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F08548E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:08:00 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j10so955299wrt.11
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:08:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Mf7AiyJak2Ddci5NSD/K/6cTFE7tFiCPl7aMiAhDtrc=;
        b=AO/BNEssfZq/FF4vgZFke59WUJ/R3U6LzD07Q+Mz7sq9K2ZYiydB/xHbQt0/1Z2X94
         NECe72hxZ9gJIDkL2uvpKNyAns4p7gTi7n9eh5/F/rI40zUUX6gcIAYGUwluziZL8dET
         maMtUWUZLsv9LiKK16xrFNeePhttFYdiO0ULm9tLdvLTsAgHFUUWLRCGEKspp9ci5BZW
         +Hd2dI0xpMXfZLKQo4ZIFcBZpQHUdDYz9hDO9WGAHHSdKgFCn9y/nyhH0BV3nRyGSN0H
         +/VS1UMkgmfAu7k4eWeeNDm5DNis/JbqQFf5U1+UTasyufUC8mFeLAnE1uUotSeR9AZm
         9rKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
X-Gm-Message-State: AJcUukd/X73+DCsEQC4J4duzG5j7pPrLIZZnHvmQRkqioCPEceb3Rf7d
	j54LNKrmpm+uQDkolHbpfK8Eqrqzelrdmot2CMD/vBpnjf5rIe3XTY5J0psDn1Jz63qumiEY3Es
	EntRAxfs6HPcvaIMB3+SFTwDPolEGflDVBXFur3tDEm2Mve4LOvmzBpp4nocSsEsS+Q==
X-Received: by 2002:a05:6000:12c4:: with SMTP id l4mr33578560wrx.134.1548936480560;
        Thu, 31 Jan 2019 04:08:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4HjBi+ZesJbzRZtWgvE4EErZvziOCO4GJTjt7nZ8fc8yXwqinDfDa6lAO5tUdmur+25mB/
X-Received: by 2002:a05:6000:12c4:: with SMTP id l4mr33578507wrx.134.1548936479719;
        Thu, 31 Jan 2019 04:07:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548936479; cv=none;
        d=google.com; s=arc-20160816;
        b=MqOpuK/gmAPD6A6+wkApMqkbcSw2YaR6k5EmAeqleQ4cE2FOV/Sg5OtNwbGinDQxTl
         vk8QaDSHZ6VMniDoPtoFnBXpnvw3q2XadmykX8K+z5hkZ98R/WiatWgAaqjZyD/PvJJH
         /cJIEqx62flIIHo5SZZ6//goEij1LFo52lT3OjH5FVzD1ZLIY1vZ1HU9qaqMw1upGbwg
         F73C/qcm3KIIah0seVMxPPIr+qxKVK3Mi13D8M8RfwPXoTRxOPY2AETaOpjBL/tCqvRq
         5acYxmWOa1bK6vEQoY/0c7vceTbwU3p16us2Wxbs5uWN272qnilkPA0FNtM2xhhRjTCa
         79fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Mf7AiyJak2Ddci5NSD/K/6cTFE7tFiCPl7aMiAhDtrc=;
        b=EyMms6T4DzJxzhW0ZDF0StKDTFSn38xE/kwRUkhJmbOSjGq9jF0FozgOMPFik24rxa
         IoPwxsmcl+HFyXU6eie2AKWY10Py5U8OtABDIkYjbUYVFtCsPCrTf7BU50cuOHwwJMkA
         bL2Zal/wB09njmOR8abtVOJ8zDummQheSYpKFCb3oYAjyOWEwKsPmjUOaRWwFIVHcDb5
         6gozx+cqbCWW7PYkx0HeTIHt6KTOR+7msI2Ko0uwDXbJ9e/cSVhPJuYmL771vVRFx3Fm
         n4K8NpTVHVk6Fa7MhTtwPN/VGAGlU9rkTYJeJMs5rYzbpfSDloXUmP9JbDA5/Ls8+7tm
         iYgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
Received: from gloria.sntech.de (gloria.sntech.de. [185.11.138.130])
        by mx.google.com with ESMTPS id n14si3190554wro.50.2019.01.31.04.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 04:07:59 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) client-ip=185.11.138.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
Received: from wf0848.dip.tu-dresden.de ([141.76.183.80] helo=phil.localnet)
	by gloria.sntech.de with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <heiko@sntech.de>)
	id 1gpB7H-0003tN-Me; Thu, 31 Jan 2019 13:06:47 +0100
From: Heiko Stuebner <heiko@sntech.de>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com, sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org, linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org, boris.ostrovsky@oracle.com, jgross@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and vm_insert_range_buggy API
Date: Thu, 31 Jan 2019 13:06:49 +0100
Message-ID: <1701923.z6LKAITQJA@phil>
In-Reply-To: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 31. Januar 2019, 04:08:12 CET schrieb Souptick Joarder:
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
> 
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
> 
> vm_insert_range() is the API which could be used to mapped
> kernel memory/pages in drivers which has considered vm_pgoff
> 
> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> 
> We _could_ then at a later "fix" these drivers which are using
> vm_insert_range_buggy() to behave according to the normal vm_pgoff
> offsetting simply by removing the _buggy suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Suggested-by: Russell King <linux@armlinux.org.uk>
> Suggested-by: Matthew Wilcox <willy@infradead.org>

hmm, I'm missing a changelog here between v1 and v2.
Nevertheless I managed to test v1 on Rockchip hardware
and display is still working, including talking to Lima via prime.

So if there aren't any big changes for v2, on Rockchip
Tested-by: Heiko Stuebner <heiko@sntech.de>

Heiko


