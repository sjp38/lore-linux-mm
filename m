Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBF92806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:36:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k91so47127115ioi.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:36:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id k8si7678721itb.73.2017.05.19.09.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 09:36:24 -0700 (PDT)
Subject: Re: [PATCH v5 01/11] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to
 bit 1
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-2-zi.yan@sent.com>
 <76a36bee-0f1c-a2f4-6f5c-78394ac46ee4@intel.com>
 <07441274-3C64-4376-8225-39CD052399B4@cs.rutgers.edu>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ea4597a9-d5a3-4f66-af44-b99f396acf66@intel.com>
Date: Fri, 19 May 2017 09:36:22 -0700
MIME-Version: 1.0
In-Reply-To: <07441274-3C64-4376-8225-39CD052399B4@cs.rutgers.edu>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

On 05/19/2017 09:31 AM, Zi Yan wrote:
>> This description lacks a problem statement.  What's the problem?
>>
>> 	_PAGE_PSE is used to distinguish between a truly non-present
>> 	(_PAGE_PRESENT=0) PMD, and a PMD which is undergoing a THP
>> 	split and should be treated as present.
>>
>> 	But _PAGE_SWP_SOFT_DIRTY currently uses the _PAGE_PSE bit,
>> 	which would cause confusion between one of those PMDs
>> 	undergoing a THP split, and a soft-dirty PMD.
>>
>> 	Thus, we need to move the bit.
>>
>> Does that capture it?
> Yes. I will add this in the next version.

OK, thanks for clarifying.  You can add my acked-by on this.

But, generally, these bits really scare me.  We don't have any nice
programmatic way to find conflicts.  I really wish we had some
BUILD_BUG_ON()s or something to express these dependencies.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
