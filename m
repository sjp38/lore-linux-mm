Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 997B06B006E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:40:50 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so179427537pdn.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:40:50 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id jc8si15266398pbd.25.2015.03.30.08.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 08:40:49 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 21:10:45 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BF1F0E0045
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:13:00 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2UFeguh43974742
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:10:42 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2UFTYuB032437
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:59:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 00/24] THP refcounting redesign
In-Reply-To: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Mon, 30 Mar 2015 21:10:41 +0530
Message-ID: <87ego6lchy.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Hello everybody,
>
> It's bug-fix update of my thp refcounting work.
>
> The goal of patchset is to make refcounting on THP pages cheaper with
> simpler semantics and allow the same THP compound page to be mapped with
> PMD and PTEs. This is required to get reasonable THP-pagecache
> implementation.
>
> With the new refcounting design it's much easier to protect against
> split_huge_page(): simple reference on a page will make you the deal.
> It makes gup_fast() implementation simpler and doesn't require
> special-case in futex code to handle tail THP pages.
>
> It should improve THP utilization over the system since splitting THP in
> one process doesn't necessary lead to splitting the page in all other
> processes have the page mapped.

Can we split this series into two. The compound_lock removal and using
migration entries ro freeze page count can be made into a seperate
series ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
