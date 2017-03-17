Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D58DD6B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:11:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u4so52157299qtc.4
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:11:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m48si6899962qtc.263.2017.03.17.10.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 10:11:47 -0700 (PDT)
Subject: Re: [PATCHv2 2/5] target/user: Add global data block pool support
References: <1488962743-17028-1-git-send-email-lixiubo@cmss.chinamobile.com>
 <1488962743-17028-3-git-send-email-lixiubo@cmss.chinamobile.com>
 <3b1ce412-6072-fda1-3002-220cf8fbf34f@redhat.com>
 <ddd797ea-43f0-b863-64e4-1e758f41dafe@cmss.chinamobile.com>
 <f4c4e83a-d6b1-ed57-7a54-4277722e5a46@cmss.chinamobile.com>
From: Andy Grover <agrover@redhat.com>
Message-ID: <2dd405f8-9f5b-405d-e744-9ee8bac77686@redhat.com>
Date: Fri, 17 Mar 2017 10:11:43 -0700
MIME-Version: 1.0
In-Reply-To: <f4c4e83a-d6b1-ed57-7a54-4277722e5a46@cmss.chinamobile.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiubo Li <lixiubo@cmss.chinamobile.com>, nab@linux-iscsi.org, mchristi@redhat.com
Cc: shli@kernel.org, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, namei.unix@gmail.com, linux-mm@kvack.org

On 03/17/2017 01:04 AM, Xiubo Li wrote:
> [...]
>> These days what I have gotten is that the unmap_mapping_range() could
>> be used.
>> At the same time I have deep into the mm code and fixed the double
>> usage of
>> the data blocks and possible page fault call trace bugs mentioned above.
>>
>> Following is the V3 patch. I have test this using 4 targets & fio for
>> about 2 days, so
>> far so good.
>>
>> I'm still testing this using more complex test case.
>>
> I have test it the whole day today:
> - using 4 targets
> - setting TCMU_GLOBAL_MAX_BLOCKS = [512 1K 1M 1G 2G]
> - each target here needs more than 450 blocks when running
> - fio: -iodepth [1 2 4 8 16] -thread -rw=[read write] -bs=[1K 2K 3K 5K
> 7K 16K 64K 1M] -size=20G -numjobs=10 -runtime=1000  ...

Hi Xiubo,

V3 is sounding very good. I look forward to reviewing it after it is posted.

Thanks -- Regards -- Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
