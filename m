Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA67CC282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:01:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 332D820881
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:01:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 332D820881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDF558E0002; Wed, 30 Jan 2019 16:01:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB7EA8E0001; Wed, 30 Jan 2019 16:01:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACC718E0002; Wed, 30 Jan 2019 16:01:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 867A18E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:01:52 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id m128so295322itd.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:01:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=2METhPUTcQdLsLxLSU+so3EI4SBEij5n3+DI87XE1zs=;
        b=elCF94Ief7ud7S4M1JkGfklZFWmVmsCb3c4c7vSgHikU6wXjv/agO4zGUVhMafWN3E
         9p4trIgDJhQ0hn1P5UU9QTaTtZqKAazXpOfJcBEO0IzzhB3Enq/EPqkqLhUwAVvTlSSt
         WWZ2qRd0smQmu0t0qYEz/oqIKjo8jUNFoNgqUStXw7L1Y+AqkO7fuza7RLFxIPsEUnhB
         m2q45upVkGUfVtvnintt8wuufmWXOz+LpapLrkXYO5RaQCNbrx6uSqHROcSFEccMTIm3
         B/eSsjduUesPpdqCDMqMkPiQAlWcPJ/xei/1IkQNFOR0rSianN3MaUJXjHjkqvlCmFI+
         5aLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukdjDbWsorOGyc0hEHkScGIJVCXfap5Vh8CCE3wOy0PefpQUU6w7
	+8uw6q9vmu7r/gQiU5GHO/O96JyBOxFHwn719Cc6EQvY2dh/+qTa/vqVt3kdJcJ7cdqJ6G2EWAE
	yyMjvFaBmYYWk/5H56zl6ZIbb26db2bCjGxzxFxTnRD2O+4nq31D9EHi6mHArsgEW4w==
X-Received: by 2002:a02:c498:: with SMTP id t24mr20963550jam.126.1548882112290;
        Wed, 30 Jan 2019 13:01:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6O0ooeEQI0lZixZB9c2i5HpIRZD4sbb3q9k1UvhID6yceuHQJbdSLeWlWBZckXNYpMxCnb
X-Received: by 2002:a02:c498:: with SMTP id t24mr20963513jam.126.1548882111611;
        Wed, 30 Jan 2019 13:01:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548882111; cv=none;
        d=google.com; s=arc-20160816;
        b=wQJJZh4FtstQ2WaaCu6fEHJRTrvGq+4hoP++0sTIA2now2xGI517upUXu1gu6zwWNV
         arI/BhGTbMlw3eYyICIm9vC/FYOpxgxstlF+TzPxnmDMIAn40YFWp+jXe06qy+Idg/Wr
         4eMokXpl29eIzJl5JGBEAjHDRj22uD1N5eY3tGH1OwtwWTSsG0KUz1nJSUEq0Eefv06N
         oIpvZkpisUNfMS+vNh5E5fukWDYTDzMakrMOsz6qGPkKxrw4zVGdFsrpIedKDmDDmKnz
         Um2fyzD4JLTO36a7fe7liIq8vaXa9+76VqtaH+IpqHHpobGEYMj8eZnpUSbiHlNAExax
         VOBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=2METhPUTcQdLsLxLSU+so3EI4SBEij5n3+DI87XE1zs=;
        b=GkDeeHDmaWxVJvaU8yoUl/T9sBJG29NNUhE9fphyYCpHHVHjq+LZbmz9NB6FrhXWgV
         hhmJca6pqL/4Mh9EYimGnBtYO1AR8HIxDT4rs1gN6Ev/jKyVKRp/oxAfLC5oCaF3t+2P
         Nvh323dB0s+w1Ki4ioh84PEN1EXvCMv9zqQF/xRI9nsSKVfk8nqz9mHFehy37vxAj5tZ
         rXA1PCrMr1Ovctw+OiRgbgaiUxylRBomvTUCYcKGKsAR38AWCw+1hAOM4Ds1nycIn8ZL
         QNSmn13oumAlmcT4gDeTjoupn9UBOtxKelzHi14G48CwldmVhj7KhmJbuaYEqe33bgVy
         9R9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id s75si1491567ios.47.2019.01.30.13.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 13:01:51 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gowzL-0000x8-U9; Wed, 30 Jan 2019 14:01:40 -0700
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Jerome Glisse <jglisse@redhat.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
References: <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
Date: Wed, 30 Jan 2019 14:01:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130195900.GG17080@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, hch@lst.de, jgg@mellanox.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-30 12:59 p.m., Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 12:45:46PM -0700, Logan Gunthorpe wrote:
>>
>>
>> On 2019-01-30 12:06 p.m., Jason Gunthorpe wrote:
>>>> Way less problems than not having struct page for doing anything
>>>> non-trivial.  If you map the BAR to userspace with remap_pfn_range
>>>> and friends the mapping is indeed very simple.  But any operation
>>>> that expects a page structure, which is at least everything using
>>>> get_user_pages won't work.
>>>
>>> GUP doesn't work anyhow today, and won't work with BAR struct pages in
>>> the forseeable future (Logan has sent attempts on this before).
>>
>> I don't recall ever attempting that... But patching GUP for special
>> pages or VMAS; or working around by not calling it in some cases seems
>> like the thing that's going to need to be done one way or another.
> 
> Remember, the long discussion we had about how to get the IOMEM
> annotation into SGL? That is a necessary pre-condition to doing
> anything with GUP in DMA using drivers as GUP -> SGL -> DMA map is
> pretty much the standard flow.

Yes, but that was unrelated to GUP even if that might have been the
eventual direction.

And I feel the GUP->SGL->DMA flow should still be what we are aiming
for. Even if we need a special GUP for special pages, and a special DMA
map; and the SGL still has to be homogenous....

> So, I see Jerome solving the GUP problem by replacing GUP entirely
> using an API that is more suited to what these sorts of drivers
> actually need.

Yes, this is what I'm expecting and what I want. Not bypassing the whole
thing by doing special things with VMAs.

Logan

