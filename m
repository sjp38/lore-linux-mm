Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id BADCD6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 05:18:04 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id at20so7964273iec.8
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 02:18:04 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id v1si23201696igk.25.2014.07.29.02.18.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 02:18:03 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id tr6so8202921ieb.21
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 02:18:03 -0700 (PDT)
Date: Tue, 29 Jul 2014 02:18:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] memory hotplug: update the variables after memory
 removed
In-Reply-To: <53D75E13.8000702@huawei.com>
Message-ID: <alpine.DEB.2.02.1407290216520.13227@chino.kir.corp.google.com>
References: <1406619310-20555-1-git-send-email-zhenzhang.zhang@huawei.com> <53D74EE5.1070308@huawei.com> <alpine.DEB.2.02.1407290046470.7998@chino.kir.corp.google.com> <53D75E13.8000702@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Dave Hansen <dave.hansen@intel.com>, mgorman@suse.de, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, 29 Jul 2014, Zhang Zhen wrote:

> >> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> >> index df1a992..fd7bd6b 100644
> >> --- a/arch/x86/mm/init_64.c
> >> +++ b/arch/x86/mm/init_64.c
> >> @@ -673,15 +673,11 @@ void __init paging_init(void)
> >>   * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
> >>   * updating.
> >>   */
> >> -static void  update_end_of_memory_vars(u64 start, u64 size)
> >> +static void  update_end_of_memory_vars(u64 end_pfn)
> > 
> > Extra space that can be removed here at the same time as a cleanup.
> > 
> Sorry, where is the extra space here?
> 

There are two spaces between the function identifier and the function 
type whereas there is traditionally only one.  It existed before your 
patch, it would just be nice to clean it up since you're already touching 
the line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
