Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2325A6B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 10:18:26 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so16673201pab.12
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 07:18:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e12si41053413pat.226.2014.08.22.07.18.24
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 07:18:25 -0700 (PDT)
Date: Fri, 22 Aug 2014 07:18:07 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20140822141807.GA5803@tassilo.jf.intel.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130411232907.GC29398@hacker.(null)>
 <20130412152237.GM16732@two.firstfloor.org>
 <20140821233729.GB2420@kernel>
 <53F69E26.1090408@cn.fujitsu.com>
 <20140822040420.GA4756@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140822040420.GA4756@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@linux.intel.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> >commit 944d9fec8d7aee3f2e16573e9b6a16634b33f403
> >Author: Luiz Capitulino <lcapitulino@redhat.com>
> >Date:   Wed Jun 4 16:07:13 2014 -0700
> >
> >    hugetlb: add support for gigantic page allocation at runtime
> >
> >
> 
> Ah, thanks for your pointing out.

I should add the CMA allocation would still make sense, as CMA would do
compaction and better pre-allocation while this does not. Should probably
revisit the issue. But it's at least partially solved now.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
