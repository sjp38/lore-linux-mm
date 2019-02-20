Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13355C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:22:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C774F2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:22:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="A2BulD4L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C774F2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57E398E002E; Wed, 20 Feb 2019 15:22:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 556648E0002; Wed, 20 Feb 2019 15:22:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41F988E002E; Wed, 20 Feb 2019 15:22:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1849C8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:22:34 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id l14so16115737ybq.7
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 12:22:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=xaPm9bOl46WttgSnpiat/PG46CKSbX8nCiFiaT9SwHE=;
        b=PD2IwYKHs0siKO4oaTcKTPc+ou+lQlm0wQjzZLb+AZt9EvMyw1jZ1P8hrS6YAPY3KQ
         q9AhAJSYFKajxdxmPHJxIREiWWBC2oKy619LIdBxIygbD59RrrWA/3Bn/1QzfFE3aiGr
         szz+g7ecI3lAugKddQJUr8fUprXcHEA0uRvxaKTndZhaIxcRvDDzPhNU3MfVYcUjVs6h
         nZYcyn7Kju00x8BpY+oAtQ8oqC9PYd8fadSHw3MEdQ1auLm0QqSPUPNRNuCI3bhrm1Yt
         KILESY45Q76VwxS7KXi/APZI96k/cr9+CXO9sWfNe09W0TtHQcO/yk1PV47x219k9Y5p
         ixxg==
X-Gm-Message-State: AHQUAuaVqiMvOet9tpd8QQaiVKH+IYxkEjeZgsH/V3IygXHxfh3IZrEv
	XwINI33zMA8+DT6EyvLuTijeY9JYtzJLnG5AwjIm7TZWxpU8hpCmpTwI4a2Jacwr1AG2vOV5LyQ
	K1iwi8t5DvU2esXKTDBu0C+klloQckDHvBShn7T/yGwpsr3uuL7SBuGv06M4O+dESKw==
X-Received: by 2002:a25:c050:: with SMTP id c77mr29504403ybf.459.1550694153776;
        Wed, 20 Feb 2019 12:22:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaMfIWE9QXy+Dk3U32q8uBcntHlHD3v8SdIbzBacd0BzT1kIjuWwwDJ0ZrQEDejTbqiMzEQ
X-Received: by 2002:a25:c050:: with SMTP id c77mr29504350ybf.459.1550694153069;
        Wed, 20 Feb 2019 12:22:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550694153; cv=none;
        d=google.com; s=arc-20160816;
        b=jWIJOsygDSqpbcNlWQ3H5u/2qLcHrHj2SvVjfbTNwgldYgNJ7dtBAHx57+XB3RIBn+
         9cpnnJrqU6gWx5CY4Fkr/DrBYjlFLrVe7E0bzRyGa5uyVRp0wd1uKUJplmO5yqjpIKLr
         VsiR5mlgWqlqEaXzQBd5q92VeMytlXlLXV/gDRZmjfjyjIcl8pULvWdE12eutpg3mfQA
         CzAakUAZMEOKzp87RN5VzUfN3lKkpi4alrVwalNWfEeaugqiSClhwH8j9n4rjzu2af6t
         7Ea/KhtP44+5I5W2jpDcT6PWFgmXq8wM8LSvD4PT8dXhNoQTFwmAalsngwIw3OzHRo8Y
         r75Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=xaPm9bOl46WttgSnpiat/PG46CKSbX8nCiFiaT9SwHE=;
        b=z4pGul9X4aSIROul8y1y+dKu8q5gJYsBrOEL7xVQ/Z5EI7fuOVf2ByW1oq4fu+Bjwu
         ANHO4O0N3TOlWgBhvUcY+38ie0yVxMHEevrchVjPyrI+B7WbCDsRcXHAjutSQjH01+I8
         i8H9OvH1KwG8d96x7FBkD5/I3gHNlky58cLXn4X7rU8/5Ks4q9iv2ubQfbzlcyVOAJrF
         RZfEwHREc02fjXj+cd/QcYjoAn19bD9KZnKWfBUN1O4HDJ076tSETVhQ1Cplj33JeKe/
         tDMz3neuq6vojIBlu7+5ObyOg7qLmz5JrRCoTibUe50ZL8HEIvrh53ZyA0OVnNdfqxSp
         +FUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=A2BulD4L;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id q11si13030753ywi.448.2019.02.20.12.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 12:22:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=A2BulD4L;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6db70d0000>; Wed, 20 Feb 2019 12:22:37 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 12:22:31 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 12:22:31 -0800
Received: from [10.2.169.124] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 20:22:30 +0000
Subject: Re: [PATCH 4/6] mm/gup: track gup-pinned pages
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <20190204052135.25784-5-jhubbard@nvidia.com>
 <20190220192405.GA12114@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2c7f6914-71ab-c3a0-d043-b25e1d55a9ce@nvidia.com>
Date: Wed, 20 Feb 2019 12:22:19 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190220192405.GA12114@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550694157; bh=xaPm9bOl46WttgSnpiat/PG46CKSbX8nCiFiaT9SwHE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=A2BulD4LCH07dOSBUhThGzWNUfUExCrX+0oDsuP3ymsZCyxIxxPfpkJbxYf5+eg0z
	 V/yOVnEg66OS94CZ/nrMqTwXu9rRqooR+mHf1aclv97tGTs1FAC9SG+Z4m4ghWkGJ6
	 6ab0eiOUU5O5OH5Mu989C3llz2w3BtQvtW7rj1UsQowRcWcFYcQvDnSOqZQF+Mrbxb
	 OK+1MKgx9135oeKn4nvT7FcIDf5VCCncUPKP9Zikx7Iyaul7JxpBqBDtx8iNUcjnsl
	 qOoNwE3nNIPHS1dN1sEjEu1na9B1iTpQSpra9ZE8xvszPKMarxCVqjghfgRtpBUO98
	 c133tkaCAR8tA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/20/19 11:24 AM, Ira Weiny wrote:
> On Sun, Feb 03, 2019 at 09:21:33PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
> [snip]
>> + *
>> + * Locking: the lockless algorithm described in page_cache_gup_pin_speculative()
>> + * and page_cache_gup_pin_speculative() provides safe operation for
> 
> Did you mean:
> 
> page_cache_gup_pin_speculative and __ page_cache_get_speculative __?
> 
> Just found this while looking at your branch.
> 
> Sorry,
> Ira
> 

Hi Ira,

Yes, thanks for catching that. I've changed it in the git repo now, and it will
show up when the next spin of this patchset goes out.

thanks,
-- 
John Hubbard
NVIDIA

