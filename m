Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2286B0012
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 12:19:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b9so6803873pgu.13
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:19:50 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id t126si6892731pfd.55.2018.04.23.09.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 09:19:49 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
References: <1524242039-64997-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180423004748.GP17484@dhcp22.suse.cz>
 <3c59a1d1-dc66-ae5f-452c-dd0adb047433@linux.alibaba.com>
 <20180423150435.GS17484@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <4d2693a6-e2eb-5108-d423-765de2bf7a19@linux.alibaba.com>
Date: Mon, 23 Apr 2018 10:19:27 -0600
MIME-Version: 1.0
In-Reply-To: <20180423150435.GS17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, kirill.shutemov@linux.intel.com
Cc: hughd@google.com, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/23/18 9:04 AM, Michal Hocko wrote:
> On Sun 22-04-18 21:28:59, Yang Shi wrote:
>>
>> On 4/22/18 6:47 PM, Michal Hocko wrote:
> [...]
>>> will be used on the first aligned address even when the initial/last
>>> portion of the mapping is not THP aligned.
>> No, my test shows it is not. And, transhuge_vma_suitable() does check the
>> virtual address alignment. If it is not huge page size aligned, it will not
>> set PMD for huge page.
> It's been quite some time since I've looked at that code but I think you
> are wrong. It just doesn't make sense to make the THP decision on the
> VMA alignment much. Kirill, can you clarify please?

In the test, QEMU is trying to mmap a file (16GB in my configuration) + 
a guard page. If the page size is 4KB, there not any pages are mapped by 
PMD, but if the page size is 2MB (huge page aligned) we can see a lot 
pages are mapped by PMD. The test result is showed in the commit log.

So, if your assumption is right, there must be something wrong in THP code.

>
> Please note that I have no objections to actually export the huge page
> size as the max block size but your changelog just doesn't make any
> sense to me.

Thanks,
Yang
