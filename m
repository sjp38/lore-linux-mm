Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA86EC10F09
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EEA8206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:34:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="C+hB89nQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EEA8206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E0B88E0003; Tue,  5 Mar 2019 20:34:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08E928E0001; Tue,  5 Mar 2019 20:34:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBFC48E0003; Tue,  5 Mar 2019 20:34:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8ADE8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 20:34:21 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v68so10559502pgb.23
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 17:34:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=fq/HESMUJWBf059BBX+oMOGMTSzOEnBoqdF74U+vpJk=;
        b=NTvOyaUFQpeG8Nat8c3O1CZb+ger4+Tyl3+AnCRv4BdW8AZ4ureRcOiwzFoYbuOhrL
         y3RfIyPpnD/yhCr2aDCrJ/8updYORowZdGJBH/ZZTM4ll6ZvE5OleKRegbWgtSAMnKYn
         2O+jySrQjUawm89WmWHYDSHA3aoZbHEIf34pErnr6iPgLqj/adf85zA7wfaGO1UwkbuH
         S9gDWlKin78nDTw2/OIoxOJbMqJ+H6ZZ1oXVcoLWlCvAME7QOhe/iV7DxlKokME7Q8XW
         VfcIQaeB9E3ha+umtIeGSUhmWTszE06fF1JWL6DlAuskyHtl1sSSudbLb2Z2bS07Lgby
         F7Eg==
X-Gm-Message-State: APjAAAXjUVjyoHogE0O1A5dxoS1KTtWug+F9adyYwDaDrs+Vb5FwshsP
	kU5PWY6B8P2nsWM5f0xpihMTtZmtE0GZJDikdu6Q6d1CnvfF9RdbFxPIFzeiIEaSahAHiyajq03
	kpyEHsTh03tztnJfOwwD53SkKgMYZ9IPA8jiILryZBCeS4heYlMUeHV5rbPWwEMF3OA==
X-Received: by 2002:a63:6c43:: with SMTP id h64mr3857969pgc.22.1551836061199;
        Tue, 05 Mar 2019 17:34:21 -0800 (PST)
X-Google-Smtp-Source: APXvYqwbQ3G8KGPNQ2x0ED1nnr8pMJZSVPSE0GnfjFmsmyKl7ltafefVqrRv2nVa3kinieohT5aS
X-Received: by 2002:a63:6c43:: with SMTP id h64mr3857904pgc.22.1551836060043;
        Tue, 05 Mar 2019 17:34:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551836060; cv=none;
        d=google.com; s=arc-20160816;
        b=TaI62cwqu2ywAxpDZwG1rb+kT+u+3McTH3Knwuhn2LE12tGBpmf7AwqjtNDmPLnFHb
         RLMglJ+wVMwISyM/CSX9C0iaWvdgmgGDN2Sg61MgDXJxx9t0qmZFLBu8IsOcLyCpwMSZ
         NWqvvhbQ/ixtvw2cbs9ipCbshZzk21pAm1oaQYz0HENg3i4iBgMsr0McTqwik33U+eRZ
         Xusdof1Mz2ilDXaFvkJYeZoiGX454RjkLuxCiWgoIv9CamtayUZFGtyeMy7lujY3UCsS
         YcH47gIh/SjzLFKWImoVOTlNlLUsz0XEQzGKT2bsymQ3lzOVSHpO7b96p59FD4vbNUlh
         k2nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=fq/HESMUJWBf059BBX+oMOGMTSzOEnBoqdF74U+vpJk=;
        b=khGO7Gd+8MzejwdWBz+vOi4ckYo5McgAOBVEeiWG2xseKOhT0TigftayAf9xe/vnIR
         5hVNpxwzDrQ4c4/Q12BVv1STHSc6KvYwlqjsLMzUkM1OFexsOaoy0cC7Fz1kIktDg2Yw
         6xfyITPAzny4Dp13YLwVVZHPsc9Tn8ZS4P5/oq0eqBQUp/36w5VhFRA4+9rLcEBuAF0J
         HEXRcw0WehURH8yTXm2CJa9sHOBvd9YKkTAflE43oP/rDoWJXnvgZgUsdUzZVpkzssig
         gXrv0YIMxQbFwUItkjKkM21FLgZ1sBhLox3jOsOTWzewYO053K7h9VGwse0hCByV+tAK
         Gp0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=C+hB89nQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id cc9si173216plb.59.2019.03.05.17.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 17:34:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=C+hB89nQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7f23930000>; Tue, 05 Mar 2019 17:34:11 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 05 Mar 2019 17:34:19 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 05 Mar 2019 17:34:19 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 6 Mar
 2019 01:34:19 +0000
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
To: Jason Gunthorpe <jgg@ziepe.ca>, Artemy Kovalyov <artemyko@mellanox.com>
CC: Ira Weiny <ira.weiny@intel.com>, "john.hubbard@gmail.com"
	<john.hubbard@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew
 Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Doug
 Ledford <dledford@redhat.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
 <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
 <20190306013213.GA1662@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <74f196a1-bd27-2e94-2f9f-0cf657eb0c91@nvidia.com>
Date: Tue, 5 Mar 2019 17:34:18 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190306013213.GA1662@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551836051; bh=fq/HESMUJWBf059BBX+oMOGMTSzOEnBoqdF74U+vpJk=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=C+hB89nQ9YW70yt0RWj8v+uzy9zwNRFfBdGoCq7bd89OCRZkNw7c4RhFusE6Eoltj
	 GMpXbfU90OsiqipDUOeIwFOG//icBckExIXFjgaJQV68QYU75RxdRib4z+1gyhSazm
	 ZPMee18ECaDRb0nJOW3B0/zNeIQd1g/12GdjipSQqjvw9xkt0Iu7IDdS1/7/ADtstZ
	 I/xJY/9Brn2KaYiqgSwJjXqEQYXLmJm8schB+66rZ/fwG5dwbr9X1xQcM98PuqrjrN
	 gbcMIHwSIVuXQZk1C0OVOSpsJTH39foJVdaIH30XHQAeda5UUBgCZVpn5w99lYBJ6X
	 HxvibPZcbpf9Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 5:32 PM, Jason Gunthorpe wrote:
> On Wed, Mar 06, 2019 at 03:02:36AM +0200, Artemy Kovalyov wrote:
>>
>>
>> On 04/03/2019 00:37, John Hubbard wrote:
>>> On 3/3/19 1:52 AM, Artemy Kovalyov wrote:
>>>>
>>>>
>>>> On 02/03/2019 21:44, Ira Weiny wrote:
>>>>>
>>>>> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>>>
>>>>>> ...
>>>
>>> OK, thanks for explaining! Artemy, while you're here, any thoughts about the
>>> release_pages, and the change of the starting point, from the other part of the
>>> patch:
>>>
>>> @@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
>>> u64 user_virt,
>>> 	mutex_unlock(&umem_odp->umem_mutex);
>>>
>>>    		if (ret < 0) {
>>> -			/* Release left over pages when handling errors. */
>>> -			for (++j; j < npages; ++j)
>> release_pages() is an optimized batch put_page() so it's ok.
>> but! release starting from page next to one cause failure in
>> ib_umem_odp_map_dma_single_page() is correct because failure flow of this
>> functions already called put_page().
>> So release_pages(&local_page_list[j+1], npages - j-1) would be correct.
> 
> Someone send a fixup patch please...
> 
> Jason

Yeah, I'm on it. Just need to double-check that this is the case. But Jason,
you're confirming it already, so that helps too.

Patch coming shortly.

thanks,
-- 
John Hubbard
NVIDIA

