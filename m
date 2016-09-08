Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08B5D6B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 14:14:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so129729268pfv.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 11:14:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id yv3si48094138pab.56.2016.09.08.11.14.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 11:14:10 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 04/10] mm, THP, swap: Add swap cluster allocate/free functions
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-5-git-send-email-ying.huang@intel.com>
	<57D121AB.8060707@linux.vnet.ibm.com>
Date: Thu, 08 Sep 2016 11:14:08 -0700
In-Reply-To: <57D121AB.8060707@linux.vnet.ibm.com> (Anshuman Khandual's
	message of "Thu, 8 Sep 2016 14:00:35 +0530")
Message-ID: <871t0u5ken.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 09/07/2016 10:16 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> The swap cluster allocation/free functions are added based on the
>> existing swap cluster management mechanism for SSD.  These functions
>> don't work for the rotating hard disks because the existing swap cluster
>> management mechanism doesn't work for them.  The hard disks support may
>> be added if someone really need it.  But that needn't be included in
>> this patchset.
>> 
>> This will be used for the THP (Transparent Huge Page) swap support.
>> Where one swap cluster will hold the contents of each THP swapped out.
>
> Which tree this series is based against ? This patch does not apply
> on the mainline kernel.

This series is based on 8/31 head of mmotm/master.  I stated it in
00/10, but I know it is hided inside other text and not obvious at all.
Is there some way to make it obvious?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
