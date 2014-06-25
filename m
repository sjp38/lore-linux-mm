Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3726B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:59:15 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so1002790pbb.39
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:59:14 -0700 (PDT)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id bg4si2928538pbb.67.2014.06.24.18.59.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 18:59:14 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so996307pbb.35
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:59:13 -0700 (PDT)
Message-ID: <53AA2CD5.6060202@gmail.com>
Date: Wed, 25 Jun 2014 09:58:45 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: update the description for madvise_remove
References: <53A9116B.9030004@gmail.com> <alpine.DEB.2.02.1406241542040.29176@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406241542040.29176@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <ak@linux.intel.com>, Vladimir Cernov <gg.kaspersky@gmail.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-man@vger.kernel.org

Patch to man-page.

[PATCH] madvise.2: update the description for MADV_REMOVE

Currently we have more filesystems supporting fallcate, e.g ext4/btrfs,
which can response to MADV_REMOVE gracefully.

And if filesystems don't support fallocate, the return error would be
EOPNOTSUPP, instead of ENOSYS.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 man2/madvise.2 | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/man2/madvise.2 b/man2/madvise.2
index 032ead7..4ce869c 100644
--- a/man2/madvise.2
+++ b/man2/madvise.2
@@ -99,13 +99,9 @@ or zero-fill-on-demand pages for mappings
 without an underlying file.
 .TP
 .BR MADV_REMOVE " (since Linux 2.6.16)"
-Free up a given range of pages
-and its associated backing store.
-Currently,
-.\" 2.6.18-rc5
-only shmfs/tmpfs supports this; other filesystems return with the
-error
-.BR ENOSYS .
+Free up a given range of pages and its associated backing store.
+Filesystems that don't support fallocate will return error
+.BR EOPNOTSUPP.
 .\" Databases want to use this feature to drop a section of their
 .\" bufferpool (shared memory segments) - without writing back to
 .\" disk/swap space.  This feature is also useful for supporting
-- 
1.8.3.2



On 2014a1'06ae??25ae?JPY 06:44, David Rientjes wrote:
> On Tue, 24 Jun 2014, Wang Sheng-Hui wrote:
> 
>>
>> Currently, we have more filesystems supporting fallocate, e.g
>> ext4/btrfs. Remove the outdated comment for madvise_remove.
>>
>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>> ---
>>  mm/madvise.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index a402f8f..0938b30 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -292,9 +292,6 @@ static long madvise_dontneed(struct vm_area_struct *vma,
>>  /*
>>   * Application wants to free up the pages and associated backing store.
>>   * This is effectively punching a hole into the middle of a file.
>> - *
>> - * NOTE: Currently, only shmfs/tmpfs is supported for this operation.
>> - * Other filesystems return -ENOSYS.
>>   */
>>  static long madvise_remove(struct vm_area_struct *vma,
>>                                 struct vm_area_struct **prev,
> 
> [For those without context: this patch has been merged into the -mm tree.]
> 
> This reference also exists in the man-page for madvise(2), are you 
> planning on removing it as well?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
