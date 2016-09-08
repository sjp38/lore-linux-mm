Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 808156B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 14:07:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g202so129825031pfb.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 11:07:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id pv7si48121014pac.166.2016.09.08.11.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 11:07:21 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP size on x86_64
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-2-git-send-email-ying.huang@intel.com>
	<57D0FB10.5010609@linux.vnet.ibm.com>
Date: Thu, 08 Sep 2016 11:07:20 -0700
In-Reply-To: <57D0FB10.5010609@linux.vnet.ibm.com> (Anshuman Khandual's
	message of "Thu, 8 Sep 2016 11:15:52 +0530")
Message-ID: <87a8fi5kpz.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 09/07/2016 10:16 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> In this patch, the size of the swap cluster is changed to that of the
>> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
>> the THP swap support on x86_64.  Where one swap cluster will be used to
>> hold the contents of each THP swapped out.  And some information of the
>> swapped out THP (such as compound map count) will be recorded in the
>> swap_cluster_info data structure.
>> 
>> For other architectures which want THP swap support, THP_SWAP_CLUSTER
>> need to be selected in the Kconfig file for the architecture.
>> 
>> In effect, this will enlarge swap cluster size by 2 times on x86_64.
>> Which may make it harder to find a free cluster when the swap space
>> becomes fragmented.  So that, this may reduce the continuous swap space
>> allocation and sequential write in theory.  The performance test in 0day
>> shows no regressions caused by this.
>
> This patch needs to be split into two separate ones
>
> (1) Add THP_SWAP_CLUSTER config option
> (2) Enable CONFIG_THP_SWAP_CLUSTER for X86_64
>
> The first patch should explain the proposal and the second patch
> should have 86_64 arch specific details, regressions etc as already
> been explained in the commit message.

The code change and possible issues is not x86_64 specific, but general
for all architectures where the config option is enabled.  If so, the
second patch becomes 1 line kconfig change and no much to be said in
patch description.  Does it deserve a separate patch?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
