Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC656B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:16:53 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id f198so64480423wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:16:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lm2si2164568wjc.202.2016.04.06.02.16.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 02:16:52 -0700 (PDT)
Subject: Re: [PATCH] cpuset: use static key better and convert to new API
References: <201604061600.UbEyxDC5%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5704D402.5040705@suse.cz>
Date: Wed, 6 Apr 2016 11:16:50 +0200
MIME-Version: 1.0
In-Reply-To: <201604061600.UbEyxDC5%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/06/2016 10:56 AM, kbuild test robot wrote:
> Hi Vlastimil,
>
> [auto build test ERROR on v4.6-rc2]
> [also build test ERROR on next-20160406]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/cpuset-use-static-key-better-and-convert-to-new-API/20160406-164542
> config: x86_64-randconfig-x011-201614 (attached as .config)
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>     mm/page_alloc.c: In function 'get_page_from_freelist':
>>> mm/page_alloc.c:2653:5: error: implicit declaration of function '__cpuset_zone_allowed' [-Werror=implicit-function-declaration]

Ah, forgot about !CONFIG_CPUSETS. Sorry, I'll send v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
