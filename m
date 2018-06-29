Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1CE36B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:39:21 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z5-v6so5232692pln.20
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:39:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h18-v6si8901104pfn.158.2018.06.29.08.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:39:20 -0700 (PDT)
Subject: Re: [PATCH v2 5/7] mm: rename and change semantics of
 nr_indirectly_reclaimable_bytes
References: <20180618091808.4419-6-vbabka@suse.cz>
 <201806201923.mC5ZpigB%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <38c6a6e1-c5e0-fd7d-4baf-1f0f09be5094@suse.cz>
Date: Fri, 29 Jun 2018 17:37:02 +0200
MIME-Version: 1.0
In-Reply-To: <201806201923.mC5ZpigB%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>

On 06/20/2018 01:23 PM, kbuild test robot wrote:
> Hi Vlastimil,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.18-rc1 next-20180619]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/kmalloc-reclaimable-caches/20180618-172912
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-allmodconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/staging//android/ion/ion_page_pool.c: In function 'ion_page_pool_remove':
>>> drivers/staging//android/ion/ion_page_pool.c:56:40: error: 'NR_INDIRECTLY_RECLAIMABLE_BYTES' undeclared (first use in this function)
>      mod_node_page_state(page_pgdat(page), NR_INDIRECTLY_RECLAIMABLE_BYTES,
>                                            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    drivers/staging//android/ion/ion_page_pool.c:56:40: note: each undeclared identifier is reported only once for each function it appears in
> 
> vim +/NR_INDIRECTLY_RECLAIMABLE_BYTES +56 drivers/staging//android/ion/ion_page_pool.c

Looks like I missed a hunk, updated patch below.

----8<----
