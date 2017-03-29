Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 902506B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 21:11:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q189so1754710pgq.17
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 18:11:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b21si2453346pgi.115.2017.03.28.18.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 18:11:01 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v7 1/9] mm, swap: Make swap cluster size same of THP size on x86_64
References: <20170328053209.25876-1-ying.huang@intel.com>
	<20170328053209.25876-2-ying.huang@intel.com>
	<20170328233056.zkp733h5kij7lfdb@node.shutemov.name>
Date: Wed, 29 Mar 2017 09:10:58 +0800
In-Reply-To: <20170328233056.zkp733h5kij7lfdb@node.shutemov.name> (Kirill
	A. Shutemov's message of "Wed, 29 Mar 2017 02:30:56 +0300")
Message-ID: <87y3voyjj1.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Mar 28, 2017 at 01:32:01PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> In this patch, the size of the swap cluster is changed to that of the
>> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
>> the THP swap support on x86_64.  Where one swap cluster will be used to
>> hold the contents of each THP swapped out.  And some information of the
>> swapped out THP (such as compound map count) will be recorded in the
>> swap_cluster_info data structure.
>> 
>> For other architectures which want THP swap support,
>> ARCH_USES_THP_SWAP_CLUSTER need to be selected in the Kconfig file for
>> the architecture.
>
> Intreseting case could be architecture with HPAGE_PMD_NR < 256.
> Can current code pack more than one THP per claster.

No.  Only one THP for each swap cluster is supported.  But in current
implementation, if HPAGE_PMD_NR < 256, the swap cluster will be < 256
too.  The size of swap cluster will be exact same as HPAGE_PMD_NR.

Best Regards,
Huang, Ying

> If not we need to have BUILG_BUG_ON() to catch attempt of such enabling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
