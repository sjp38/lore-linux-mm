Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 0F4246B005D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 02:54:53 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 7 Dec 2012 13:24:34 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 03EAEE004D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 13:24:23 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB77sj1925165972
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 13:24:45 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB77sjn6018030
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 18:54:45 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned hugepage
In-Reply-To: <1354860882-14567-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1354860882-14567-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 07 Dec 2012 13:24:45 +0530
Message-ID: <878v9acn5m.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> On Fri, Dec 07, 2012 at 11:06:41AM +0530, Aneesh Kumar K.V wrote:
> ...
>> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> > Date: Thu, 6 Dec 2012 20:54:30 -0500
>> > Subject: [PATCH v2] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned
>> >  hugepage
>> >
>> > This patch fixes the warning from __list_del_entry() which is triggered
>> > when a process tries to do free_huge_page() for a hwpoisoned hugepage.
>> 
>> 
>> Can you get a dump stack for that. I am confused because the page was
>> already in freelist, and we deleted it from the list and set the
>> refcount to 1. So how are we reaching free_huge_page() again ?
>
> free_huge_page() can be called for hwpoisoned hugepage from unpoison_memory().
> This function gets refcount once and clears PageHWPoison, and then puts
> refcount twice to return the hugepage back to free pool.
> The second put_page() finally reaches free_huge_page().
>

Can we add this also to the commit message ?. With that you can add

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
