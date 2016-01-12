Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id EB82F680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 22:25:37 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id ba1so425570282obb.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:25:37 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z4si25158637oeq.54.2016.01.11.19.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 19:25:37 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole
 punch
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
 <20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
 <56943D00.7090405@oracle.com>
 <20160111162931.0bea916e.akpm@linux-foundation.org>
 <569458AB.5000102@oracle.com>
 <20160111182010.bc4e171b.akpm@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5694712B.6040705@oracle.com>
Date: Mon, 11 Jan 2016 19:21:15 -0800
MIME-Version: 1.0
In-Reply-To: <20160111182010.bc4e171b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>

On 01/11/2016 06:20 PM, Andrew Morton wrote:
> On Mon, 11 Jan 2016 17:36:43 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>>>
>>> I'll mark this patch as "pending, awaiting Mike's go-ahead".
>>>
>>
>> When this patch was originally submitted, bugs were discovered in the
>> hugetlb_vmdelete_list routine.  So, the patch "Fix bugs in
>> hugetlb_vmtruncate_list" was created.
>>
>> I have retested the changes in this patch specifically dealing with
>> page fault/hole punch race on top of the new hugetlb_vmtruncate_list
>> routine.  Everything looks good.
>>
>> How would you like to proceed with the patch?
>> - Should I create a series with the hugetlb_vmtruncate_list split out?
>> - Should I respin with hugetlb_vmtruncate_list patch applied?
>>
>> Just let me know what is easiest/best for you.
> 
> If you're saying that
> http://ozlabs.org/~akpm/mmots/broken-out/mm-mempolicy-skip-non-migratable-vmas-when-setting-mpol_mf_lazy.patch

That should be,
http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlbfs-fix-bugs-in-hugetlb_vmtruncate_list.patch

> and
> http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlbfs-unmap-pages-if-page-fault-raced-with-hole-punch.patch
> are the final everything-works versions then we're all good to go now.
> 

The only thing that 'might' be an issue is the new reference to
hugetlb_vmdelete_list() from remove_inode_hugepages().
hugetlb_vmdelete_list() was after remove_inode_hugepages() in the source
file.

The original patch moved hugetlb_vmdelete_list() to satisfy the new
reference.  I can not tell if that was taken into account in the way the
patches were pulled into your tree.  Will certainly know when it comes
time to build.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
