Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 345B06B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 01:34:34 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b5-v6so1258062ple.20
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 22:34:34 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id a21-v6si4907535pgm.417.2018.07.04.22.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 22:34:33 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
References: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
 <5c7996b8e6d31541f3185f8e4064ff97582c86f8.1530716899.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4gjFVG7tHv65Z=FsZ9=5wXDxNWawFJqO8MkyMudch4zDw@mail.gmail.com>
From: zhangyi6 <yi.z.zhang@intel.com>
Message-ID: <c5fad961-05ea-73da-7fda-f48c910136d9@intel.com>
Date: Thu, 5 Jul 2018 21:20:35 +0800
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gjFVG7tHv65Z=FsZ9=5wXDxNWawFJqO8MkyMudch4zDw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com



On 2018a1'07ae??04ae?JPY 22:50, Dan Williams wrote:
> On Wed, Jul 4, 2018 at 8:30 AM, Zhang Yi <yi.z.zhang@linux.intel.com> wrote:
>> Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
>> other reserved PFNs, pages on NVDIMM shall still behave like normal ones
>> in many cases, i.e. when used as backend memory of KVM guest. This patch
>> introduces a new memory type, MEMORY_DEVICE_DEV_DAX. Together with the
>> existing type MEMORY_DEVICE_FS_DAX, we can differentiate the pages on
>> NVDIMM with the normal reserved pages.
>>
>> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
>> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
>> ---
>>  drivers/dax/pmem.c       | 1 +
>>  include/linux/memremap.h | 1 +
>>  2 files changed, 2 insertions(+)
>>
>> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
>> index fd49b24..fb3f363 100644
>> --- a/drivers/dax/pmem.c
>> +++ b/drivers/dax/pmem.c
>> @@ -111,6 +111,7 @@ static int dax_pmem_probe(struct device *dev)
>>                 return rc;
>>
>>         dax_pmem->pgmap.ref = &dax_pmem->ref;
>> +       dax_pmem->pgmap.type = MEMORY_DEVICE_DEV_DAX;
>>         addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
>>         if (IS_ERR(addr))
>>                 return PTR_ERR(addr);
>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> index 5ebfff6..4127bf7 100644
>> --- a/include/linux/memremap.h
>> +++ b/include/linux/memremap.h
>> @@ -58,6 +58,7 @@ enum memory_type {
>>         MEMORY_DEVICE_PRIVATE = 1,
>>         MEMORY_DEVICE_PUBLIC,
>>         MEMORY_DEVICE_FS_DAX,
>> +       MEMORY_DEVICE_DEV_DAX,
> Please add documentation for this new type to the comment block about
> this definition.
Thanks for your comments Dan, Will add it in next version,
Regards
Yi.
