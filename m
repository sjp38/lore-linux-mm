Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 15AFA6B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:35:11 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so1541150pab.17
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:35:11 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id sz7si16640115pab.319.2014.01.13.12.35.10
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 12:35:10 -0800 (PST)
Message-ID: <52D44DF9.3060903@fb.com>
Date: Mon, 13 Jan 2014 15:35:05 -0500
From: Josef Bacik <jbacik@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] shmem: init on stack vmas
References: <1389638777-31891-1-git-send-email-jbacik@fb.com> <52D44D55.2090709@intel.com>
In-Reply-To: <52D44D55.2090709@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org


On 01/13/2014 03:32 PM, Dave Hansen wrote:
> On 01/13/2014 10:46 AM, Josef Bacik wrote:
>> We were hitting a weird bug with our cgroup stuff because shmem uses on stack
>> vmas.  These aren't properly init'ed so we'd have garbage in vma->mm and bad
>> things would happen.  Fix this by just init'ing to empty structs.  Thanks,
> ...
>>   static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
>>   			struct shmem_inode_info *info, pgoff_t index)
>>   {
>> -	struct vm_area_struct pvma;
>> +	struct vm_area_struct pvma = {};
> What does that code do if it needs an mm and doesn't find one?
We have checks for if (vma->mm && some other shit) so we expect NULLs 
for stuff we don't care about.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
