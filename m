Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31B156B0392
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:29:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u48so12439426wrc.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 01:29:20 -0700 (PDT)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id p199si2215951wmd.130.2017.03.17.01.29.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 01:29:18 -0700 (PDT)
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <20170316134321.c5cf727c21abf89b7e6708a2@linux-foundation.org>
 <20170316234950.GA5725@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <3ff0fc0b-eb2a-a0d2-d8f6-82045a445324@huawei.com>
Date: Fri, 17 Mar 2017 16:29:10 +0800
MIME-Version: 1.0
In-Reply-To: <20170316234950.GA5725@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David
 Nellans <dnellans@nvidia.com>

On 2017/3/17 7:49, Jerome Glisse wrote:
> On Thu, Mar 16, 2017 at 01:43:21PM -0700, Andrew Morton wrote:
>> On Thu, 16 Mar 2017 12:05:19 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
>>
>>> Cliff note:
>>
>> "Cliff's notes" isn't appropriate for a large feature such as this. 
>> Where's the long-form description?  One which permits readers to fully
>> understand the requirements, design, alternative designs, the
>> implementation, the interface(s), etc?
>>
>> Have you ever spoken about HMM at a conference?  If so, the supporting
>> presentation documents might help here.  That's the level of detail
>> which should be presented here.
> 
> Longer description of patchset rational, motivation and design choices
> were given in the first few posting of the patchset to which i included
> a link in my cover letter. Also given that i presented that for last 3
> or 4 years to mm summit and kernel summit i thought that by now peoples
> were familiar about the topic and wanted to spare them the long version.
> My bad.
> 
> I attach a patch that is a first stab at a Documentation/hmm.txt that
> explain the motivation and rational behind HMM. I can probably add a
> section about how to use HMM from device driver point of view.
> 

Please, that would be very helpful!

> +3) Share address space and migration
> +
> +HMM intends to provide two main features. First one is to share the address
> +space by duplication the CPU page table into the device page table so same
> +address point to same memory and this for any valid main memory address in
> +the process address space.

Is this an optional feature?
I mean the device don't have to duplicate the CPU page table.
But only make use of the second(migration) feature.

> +The second mechanism HMM provide is a new kind of ZONE_DEVICE memory that does
> +allow to allocate a struct page for each page of the device memory. Those page
> +are special because the CPU can not map them. They however allow to migrate
> +main memory to device memory using exhisting migration mechanism and everything
> +looks like if page was swap out to disk from CPU point of view. Using a struct
> +page gives the easiest and cleanest integration with existing mm mechanisms.
> +Again here HMM only provide helpers, first to hotplug new ZONE_DEVICE memory
> +for the device memory and second to perform migration. Policy decision of what
> +and when to migrate things is left to the device driver.
> +
> +Note that any CPU acess to a device page trigger a page fault which initiate a
> +migration back to system memory so that CPU can access it.

A bit confused here, do you mean CPU access to a main memory page but that page has been migrated to device memory?
Then a page fault will be triggered and initiate a migration back.

Thanks,
Bob


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
