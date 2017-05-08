Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 245B46B03B7
	for <linux-mm@kvack.org>; Mon,  8 May 2017 01:57:31 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id a20so55885842itb.1
        for <linux-mm@kvack.org>; Sun, 07 May 2017 22:57:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l74si12214826iod.94.2017.05.07.22.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 22:57:30 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <c395f4ce-0f18-5550-6344-67ac9a152e9f@oracle.com>
Date: Sun, 7 May 2017 22:57:19 -0700
MIME-Version: 1.0
In-Reply-To: <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 5/3/17 12:02 PM, Prakash Sangappa wrote:
> On 5/2/17 4:43 PM, Dave Hansen wrote:
>
>> Ideally, it would be something that is *not* specifically for hugetlbfs.
>>   MADV_NOAUTOFILL, for instance, could be defined to SIGSEGV whenever
>> memory is touched that was not populated with MADV_WILLNEED, mlock(), 
>> etc...
>
> If this is a generic advice type, necessary support will have to be 
> implemented
> in various filesystems which can support this.
>
> The proposed behavior for 'noautofill' was to not fill holes in 
> files(like sparse files).
> In the page fault path, mm would not know if the mmapped address on which
> the fault occurred, is over a hole in the file or just that the page 
> is not available
> in the page cache. The underlying filesystem would be called and it 
> determines
> if it is a hole and that is where it would fail and not fill the hole, 
> if this support is added.
> Normally, filesystem which support sparse files(holes in file) 
> automatically fill the hole
> when accessed. Then there is the issue of file system block size and 
> page size. If the
> block sizes are smaller then page size, it could mean the noautofill 
> would only work
> if the hole size is equal to  or a multiple of, page size?
>
> In case of hugetlbfs it is much straight forward. Since this 
> filesystem is not like a normal
> filesystems and and the file sizes are multiple of huge pages. The 
> hole will be a multiple
> of the huge page size. For this reason then should the advise be 
> specific to hugetlbfs?
>
>


Any further comments? I think introducing a general madvise option or a 
mmap flag applicable to all filesystems, may not be required. The 
'noautofill' behavior would be specifically useful in hugetlbfs filesystem.

So, if it is specific to hugetlbfs, will the mount option be ok? 
Otherwise adding a madvise / mmap option specific to hugetlbfs, be 
preferred?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
