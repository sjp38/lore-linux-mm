Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6285E6B0262
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:26:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so5278560pab.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 08:26:19 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id j190si6911521pfc.151.2016.07.27.08.26.18
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 08:26:18 -0700 (PDT)
Subject: Re: [RFC PATCH] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
References: <1469547868-9814-1-git-send-email-hejianet@gmail.com>
 <579788BA.1040706@linux.intel.com> <579810E7.6060601@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5798D299.4090904@linux.intel.com>
Date: Wed, 27 Jul 2016 08:26:17 -0700
MIME-Version: 1.0
In-Reply-To: <579810E7.6060601@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hejianet <hejianet@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

On 07/26/2016 06:39 PM, hejianet wrote:
>>>
>> and you choose to patch both of the alloc_*() functions.  Why not just
>> fix it at the common call site?  Seems like that
>> spin_lock(&hugetlb_lock) could be a cond_resched_lock() which would fix
>> both cases.
> I agree to move the cond_resched() to a common site in 
> set_max_huge_pages(). But do you mean the spin_lock in this while
> loop can be replaced by cond_resched_lock? IIUC, cond_resched_lock =
> spin_unlock+cond_resched+spin_lock. So could you please explain more
> details about it? Thanks.

Ahh, good point.  A plain cond_resched() outside the lock is probably
sufficient here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
