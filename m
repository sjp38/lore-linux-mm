Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2705A6B025E
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 07:33:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so6328088wma.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 04:33:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z133si17754109wmc.158.2016.12.09.04.33.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 04:33:32 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, page_alloc: don't convert pfn to idx when merging
References: <201612092050.PFZ1Jc0w%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <114c06f4-f299-132f-7267-847857a45bcc@suse.cz>
Date: Fri, 9 Dec 2016 13:33:26 +0100
MIME-Version: 1.0
In-Reply-To: <201612092050.PFZ1Jc0w%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On 12/09/2016 01:14 PM, kbuild test robot wrote:
> Hi Vlastimil,
>
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.9-rc8 next-20161208]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/mm-page_alloc-don-t-convert-pfn-to-idx-when-merging/20161209-192634
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-s1-201649 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All errors (new ones prefixed by >>):
>
>    mm/page_isolation.c: In function 'unset_migratetype_isolate':
>>> mm/page_isolation.c:106:16: error: implicit declaration of function '__find_buddy_index' [-Werror=implicit-function-declaration]
>        buddy_idx = __find_buddy_index(page_idx, order);
>                    ^~~~~~~~~~~~~~~~~~

Looks like my .config was missing MEMORY_ISOLATION. Fix is trivial and 
will include in v2 eventually after feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
