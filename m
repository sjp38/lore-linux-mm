Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FE27C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 20:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEC84218D2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 20:45:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="sAWi2INA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEC84218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6505B8E009A; Fri,  8 Feb 2019 15:45:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D9E38E0002; Fri,  8 Feb 2019 15:45:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 453EC8E009A; Fri,  8 Feb 2019 15:45:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 081198E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 15:45:02 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id e10so2950922ybr.18
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 12:45:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ogIholLrpKztcsDoAScWgBL1e5vfshGcZY+vwNC42rg=;
        b=OBf5SV0YSAwtZDAprTqIAR0OTt+le5oqPqqjZFVOaE1ExNqvXpYUYC0rBuV5EFBuGR
         0PzBR9OYbYb0UYXFXm4OySrTx+x+ethAiH1kQX0luUaUHvvqmZkBVJxBqJKePCvVFn8L
         PIaG1ciIoXNdXVABdQ3vPb3uFoLgsAJBJs+HcVSEBGZCyqEWTBcsXCR3wJqhW2Bek6bY
         2F1j08UbW8qRfq7vGH9UxIda68VWmZKovBDafF3+oe7CUnya4Fik8ZKMaH50MUKhlV1X
         ZwtR6BTpHLu37Lu6/Xh/gmqmgs5baLFM3AdZZoqIh1vWsfxyA+9KGGc6B99U+ULSwZXf
         vs5Q==
X-Gm-Message-State: AHQUAubLHXqRi4GKri8IF+YF045wTHX4QTbwpF44Ilm0gbHabr6qR0zF
	TJTyr9yut89jy2hdZT9+CzNFZTKDrQcB9ttb55y68YGULIitBc/5dnRcNGxgjFjGPVNccLihOxv
	rxjtv74u90DgGTt8LSpf57GPpqokcjlBlyI2TnuhruIPek7C63Vtw/6Bm0RdgvtHDrg==
X-Received: by 2002:a81:3c47:: with SMTP id j68mr8611421ywa.69.1549658701715;
        Fri, 08 Feb 2019 12:45:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaL62fx5buWtadm76RwkVgGAYGBMm4Nb2HXoOQyHq3me1vUbs2dpe8vAFqUELWH5z6iTPIG
X-Received: by 2002:a81:3c47:: with SMTP id j68mr8611383ywa.69.1549658700950;
        Fri, 08 Feb 2019 12:45:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549658700; cv=none;
        d=google.com; s=arc-20160816;
        b=Avv83o4RBhrDjbjsFyNjtlN4judKfaGyg/bCHtuwCx0wvs90mOURu3cwwuMZg6+/m/
         Vo3s6p6PWJMGONON9qPiPSW7gHT7BGYkhMs1HVpxTJ/6q2j2GcykzsD9z6A97AYo2xwV
         ItbpjzDmCiEqtF7XHI/huCO82y7/2kpiAl8FddvRG7ac87/YNxG8dMeeQcGJnWZe3wgc
         3z5sCyKyi1RhYHkLtB7CBWxbmtviL28zhODoTSXhMcfRaNj8cfLBiF9NmBISnbVzk/fF
         /gR/Z78O5Gy7lHCfQXJkoFvSUx4dbkQ/CJmLWs7lBCWZFHi3DeNMOgAOlPDFkbXVHoz5
         YFXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ogIholLrpKztcsDoAScWgBL1e5vfshGcZY+vwNC42rg=;
        b=no+RWe3xs0aukOaIBX2xBZZ2CcbcLdj3OdeYBWZ4uRPZpo1Cs8knd6pRAGcpWkMP0A
         8oK0SicHvHbB5lkAj92f8qoeCjzY7WGsDbA9BsTmYKpzBB8NT7mLXDPmXhtweeFq3Kdw
         JwNyzrgbk2ryJC9CQOGIJ6E+kPIWD0QiIiPFbAXReQfNJ2Jb/5dj+1nZYrkcFTQ3hmow
         dtRwJjFEtw0IK47/WvzsHZX7A/iaodPE8QufMxYrirv8oQG3tdpifM87S2ghl5xvbkX8
         55DIu7+K0LKd0FCR2wIouc0IbOa4W3w2MBVfvi8DK4I9mKp5J1I13PHdzSfU6LZGAZdC
         2aqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=sAWi2INA;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id j83si1834413ywa.51.2019.02.08.12.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 12:45:00 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=sAWi2INA;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c5dea4f0000>; Fri, 08 Feb 2019 12:45:03 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 08 Feb 2019 12:44:59 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 08 Feb 2019 12:44:59 -0800
Received: from [10.2.164.159] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 8 Feb
 2019 20:44:58 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Mike Rapoport <rppt@linux.ibm.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190208075649.3025-1-jhubbard@nvidia.com>
 <20190208075649.3025-2-jhubbard@nvidia.com>
 <20190208103211.GD11096@rapoport-lnx>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9c1985cc-cd99-a950-5ea2-9df9f93eb98b@nvidia.com>
Date: Fri, 8 Feb 2019 12:44:48 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190208103211.GD11096@rapoport-lnx>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549658703; bh=ogIholLrpKztcsDoAScWgBL1e5vfshGcZY+vwNC42rg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=sAWi2INAdMFVha1o+0PxFQFpRxw0XUDZH6EHdS0tXI6IMWQabh2rAzTr96FGKQxAK
	 r0aikr3jTyoS3DxaYwrKX5T7q8ls1Aq584uHk8oBkugOH6hSCm3cDIQyxqepV0cPOn
	 QuUVL0k04OQP5WPYD9lo2wvJbSKKRMl3l9Xoaqhcad5u/ej2y8PCq9Y/ViixMdQHKb
	 kLoMbizF1iqWwlOGrhJoNu2oVKogaWbBomZlQxjQ6TdKT504r9P8hqkIi9AwKZnZB1
	 8OpYjxjN40TYgY15Ro/ABg0ylD2edugYItbNuT4lLwlr8I6X5zIoOE1csq+a+zruhC
	 5itwstqUV7DNw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/8/19 2:32 AM, Mike Rapoport wrote:
> On Thu, Feb 07, 2019 at 11:56:48PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
[...]
>> +/**
>> + * put_user_page() - release a gup-pinned page
>> + * @page:            pointer to page to be released
>> + *
>> + * Pages that were pinned via get_user_pages*() must be released via
>> + * either put_user_page(), or one of the put_user_pages*() routines
>> + * below. This is so that eventually, pages that are pinned via
>> + * get_user_pages*() can be separately tracked and uniquely handled. In
>> + * particular, interactions with RDMA and filesystems need special
>> + * handling.
>> + *
>> + * put_user_page() and put_page() are not interchangeable, despite this early
>> + * implementation that makes them look the same. put_user_page() calls must
> 
> I just hope we'll remember to update when the real implementation will be
> merged ;-)
> 
> Other than that, feel free to add
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>	# docs
> 

Thanks for the review!

Yes, the follow-on patch that turns this into a real implementation is
posted [1], and its documentation is updated accordingly.

(I've already changed "@Returns" to "@Return" locally in that patch, btw.)

[1] https://lore.kernel.org/r/20190204052135.25784-5-jhubbard@nvidia.com

thanks,
-- 
John Hubbard
NVIDIA

