Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2A46B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 08:19:04 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id h10so1580025eak.14
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 05:19:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j48si2795431eew.142.2014.02.07.05.19.02
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 05:19:03 -0800 (PST)
Message-ID: <52F4DD26.4020906@redhat.com>
Date: Fri, 07 Feb 2014 08:18:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] mm: Remove ifdef condition in include/linux/mm.h
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com>
In-Reply-To: <63adb3b97f2869d4c7e76d17ef4aa76b8cf599f3.1391167128.git.rashika.kheria@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, josh@joshtriplett.org

On 02/07/2014 07:15 AM, Rashika Kheria wrote:
> The ifdef conditions in include/linux/mm.h presents three cases:
> 
> - !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
> There is no actual definition of function but include/linux/mm.h has a
> static inline stub defined.
> 
> - defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
> linux/mm.h does not define a prototype, but mm/page_alloc.c defines
> the function.
> Hence, compiler reports the following warning:
> mm/page_alloc.c:4300:15: warning: no previous prototype for a??__early_pfn_to_nida?? [-Wmissing-prototypes]
> 
> - defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
> The architecture defines the function, and linux/mm.h has a prototype.
> 
> Thus, join the conditions of Case 2 and 3 i.e. eliminate the ifdef
> condition of CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID to eliminate the
> missing prototype warning from file mm/page_alloc.c.
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
