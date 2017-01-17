Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2E96B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 03:17:28 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j13so163645339iod.6
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 00:17:28 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id w71si11703402ith.22.2017.01.17.00.17.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 00:17:28 -0800 (PST)
Message-ID: <587DD24B.2000709@huawei.com>
Date: Tue, 17 Jan 2017 16:14:03 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: respect pre-allocated storage mapping for memmap
References: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com> <efc34702-7921-a91c-3002-691f083001d5@linux.vnet.ibm.com>
In-Reply-To: <efc34702-7921-a91c-3002-691f083001d5@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: dan.j.williams@intel.com, hannes@cmpxchg.org, mhocko@suse.com, linux-mm@kvack.org

On 2017/1/16 22:43, Anshuman Khandual wrote:
> On 01/16/2017 07:08 PM, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> At present, we skip the reservation storage by the driver for
>> the zone_dvice. but the free pages set aside for the memmap is
>> ignored. And since the free pages is only used as the memmap,
>> so we can also skip the corresponding pages.
> But these free pages used for memmap mapping should also be accounted
> inside the zone, no ?
  That's confusing.  because first_pfn for zone_device after reserve and free page for
 memmap mapping.  That is used as a actuallly pfn for zone_device.

 Thanks
 zhongjiang
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
