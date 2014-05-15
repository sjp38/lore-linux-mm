Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 90ABF6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 04:25:21 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so798988pbb.19
        for <linux-mm@kvack.org>; Thu, 15 May 2014 01:25:21 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id rm9si2301340pbc.251.2014.05.15.01.25.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 May 2014 01:25:20 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Thu, 15 May 2014 13:55:17 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E77211258053
	for <linux-mm@kvack.org>; Thu, 15 May 2014 13:54:16 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4F8PNPd9240966
	for <linux-mm@kvack.org>; Thu, 15 May 2014 13:55:23 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4F8PC21001766
	for <linux-mm@kvack.org>; Thu, 15 May 2014 13:55:13 +0530
Message-ID: <537479E7.90806@linux.vnet.ibm.com>
Date: Thu, 15 May 2014 13:55:11 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
In-Reply-To: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com


Hi Ingo,

	Do you have any comments for the latest version of the patchset. If
not, kindly can you pick it up as is.


With regards
Maddy

> Kirill A. Shutemov with 8c6e50b029 commit introduced
> vm_ops->map_pages() for mapping easy accessible pages around
> fault address in hope to reduce number of minor page faults.
> 
> This patch creates infrastructure to modify the FAULT_AROUND_ORDER
> value using mm/Kconfig. This will enable architecture maintainers
> to decide on suitable FAULT_AROUND_ORDER value based on
> performance data for that architecture. First patch also defaults
> FAULT_AROUND_ORDER Kconfig element to 4. Second patch list
> out the performance numbers for powerpc (platform pseries) and
> initialize the fault around order variable for pseries platform of
> powerpc.
> 
> V4 Changes:
>   Replaced the BUILD_BUG_ON with VM_BUG_ON.
>   Moved fault_around_pages() and fault_around_mask() functions outside of
>    #ifdef CONFIG_DEBUG_FS.
> 
> V3 Changes:
>   Replaced FAULT_AROUND_ORDER macro to a variable to support arch's that
>    supports sub platforms.
>   Made changes in commit messages.
> 
> V2 Changes:
>   Created Kconfig parameter for FAULT_AROUND_ORDER
>   Added check in do_read_fault to handle FAULT_AROUND_ORDER value of 0
>   Made changes in commit messages.
> 
> Madhavan Srinivasan (2):
>   mm: move FAULT_AROUND_ORDER to arch/
>   powerpc/pseries: init fault_around_order for pseries
> 
>  arch/powerpc/platforms/pseries/pseries.h |    2 ++
>  arch/powerpc/platforms/pseries/setup.c   |    5 +++++
>  mm/Kconfig                               |    8 ++++++++
>  mm/memory.c                              |   25 ++++++-------------------
>  4 files changed, 21 insertions(+), 19 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
