Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 080BB6B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 14:15:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x24so129768805pfa.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 11:15:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id ct9si48085496pad.134.2016.09.08.11.15.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 11:15:14 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 03/10] mm, memcg: Support to charge/uncharge multiple swap entries
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-4-git-send-email-ying.huang@intel.com>
	<57D12134.40604@linux.vnet.ibm.com>
Date: Thu, 08 Sep 2016 11:15:13 -0700
In-Reply-To: <57D12134.40604@linux.vnet.ibm.com> (Anshuman Khandual's message
	of "Thu, 8 Sep 2016 13:58:36 +0530")
Message-ID: <87wpim45se.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 09/07/2016 10:16 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> This patch make it possible to charge or uncharge a set of continuous
>> swap entries in the swap cgroup.  The number of swap entries is
>> specified via an added parameter.
>> 
>> This will be used for the THP (Transparent Huge Page) swap support.
>> Where a swap cluster backing a THP may be allocated and freed as a
>> whole.  So a set of continuous swap entries (512 on x86_64) backing one
>
> Please use HPAGE_SIZE / PAGE_SIZE instead of hard coded number like 512.

Sure.  Will change it.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
