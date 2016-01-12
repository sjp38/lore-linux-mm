Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 56B83680F84
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:39:29 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id mw1so122177233igb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:39:29 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e91si4362141ioi.138.2016.01.11.17.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 17:39:28 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole
 punch
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
 <20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
 <56943D00.7090405@oracle.com>
 <20160111162931.0bea916e.akpm@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <569458AB.5000102@oracle.com>
Date: Mon, 11 Jan 2016 17:36:43 -0800
MIME-Version: 1.0
In-Reply-To: <20160111162931.0bea916e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>

On 01/11/2016 04:29 PM, Andrew Morton wrote:
> On Mon, 11 Jan 2016 15:38:40 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> On 01/11/2016 02:35 PM, Andrew Morton wrote:
>>> On Wed,  6 Jan 2016 14:37:04 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

<snip>

>>>> The (unmodified) routine hugetlb_vmdelete_list was moved ahead of
>>>> remove_inode_hugepages to satisfy the new reference.
>>>>

<snip>

> 
> I'll mark this patch as "pending, awaiting Mike's go-ahead".
> 

When this patch was originally submitted, bugs were discovered in the
hugetlb_vmdelete_list routine.  So, the patch "Fix bugs in
hugetlb_vmtruncate_list" was created.

I have retested the changes in this patch specifically dealing with
page fault/hole punch race on top of the new hugetlb_vmtruncate_list
routine.  Everything looks good.

How would you like to proceed with the patch?
- Should I create a series with the hugetlb_vmtruncate_list split out?
- Should I respin with hugetlb_vmtruncate_list patch applied?

Just let me know what is easiest/best for you.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
