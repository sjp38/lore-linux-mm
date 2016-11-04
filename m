Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24BF328025A
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 22:30:39 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id bi5so8181375pad.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:30:39 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 201si13037250pfc.120.2016.11.03.19.30.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 19:30:38 -0700 (PDT)
Message-ID: <581BF0D0.9010400@huawei.com>
Date: Fri, 4 Nov 2016 10:22:08 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] hugetlbfs: fix the hugetlbfs can not be mounted
References: <1477721311-54522-1-git-send-email-zhongjiang@huawei.com> <20161103121721.50040185d201e3aac27fd366@linux-foundation.org>
In-Reply-To: <20161103121721.50040185d201e3aac27fd366@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: nyc@holomorphy.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, rientjes@google.com, hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Gortmaker <paul.gortmaker@windriver.com>

On 2016/11/4 3:17, Andrew Morton wrote:
> On Sat, 29 Oct 2016 14:08:31 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> Since 'commit 3e89e1c5ea84 ("hugetlb: make mm and fs code explicitly non-modular")'
>> bring in the mainline. mount hugetlbfs will result in the following issue.
>>
>> mount: unknown filesystme type 'hugetlbfs'
>>
>> because previous patch remove the module_alias_fs, when we mount the fs type,
>> the caller get_fs_type can not find the filesystem.
>>
>> The patch just recover the module_alias_fs to identify the hugetlbfs.
> hm, 3e89e1c5ea84 ("hugetlb: make mm and fs code explicitly
> non-modular") was merged almost a year ago.  And you are apparently the
> first person to discover this regression.  Can you think why that is?
  when I pull the upstream patch in 4.9-rc2. I find that I cannot mount the hugetlbfs.
  but when I pull  the upstream remain patch in the next day.  I test again. it  work well.
  so I reply the mail right now,  please ignore the patch.  The detailed reason is not digged.

  I am sorry for wasting your time.

  Thanks you
  zhongjiang
>> index 4fb7b10..b63e7de 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/security.h>
>>  #include <linux/magic.h>
>>  #include <linux/migrate.h>
>> +#include <linux/module.h>
>>  #include <linux/uio.h>
>>  
>>  #include <asm/uaccess.h>
>> @@ -1209,6 +1210,7 @@ static struct dentry *hugetlbfs_mount(struct file_system_type *fs_type,
>>  	.mount		= hugetlbfs_mount,
>>  	.kill_sb	= kill_litter_super,
>>  };
>> +MODULE_ALIAS_FS("hugetlbfs");
>>  
>>  static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
>>  
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
