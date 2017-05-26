Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE8C6B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:59:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so248811211pfd.11
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:59:05 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f12si30205448pln.103.2017.05.25.17.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:59:03 -0700 (PDT)
Date: Fri, 26 May 2017 08:58:59 +0800
From: Fengguang Wu <lkp@intel.com>
Subject: Re: [PATCH v6 05/10] mm: thp: enable thp migration in generic path
Message-ID: <20170526005859.e3idib4um3cxcpqs@wfg-t540p.sh.intel.com>
References: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
 <138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
 <20170525154328.61a2b2ceef37183895d5ce43@linux-foundation.org>
 <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com

Hi Yan,

>The bug is present in gcc 4.8 and 4.9 and m68k has newer gcc to use,
>so kbuild test robot needs to upgrade its m68k gcc (maybe it has done it).

FYI Debian has gcc-6 package for m68k and we're using it.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
