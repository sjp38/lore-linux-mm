Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48F736B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 12:19:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r203so3963737wmb.2
        for <linux-mm@kvack.org>; Wed, 31 May 2017 09:19:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s199si19349314wmd.7.2017.05.31.09.19.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 09:19:32 -0700 (PDT)
Date: Wed, 31 May 2017 09:19:19 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [RFC v2 10/10] mm: Introduce CONFIG_MEM_RANGE_LOCK
Message-ID: <20170531161919.GC28615@linux-80c1.suse>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1495624801-8063-11-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1495624801-8063-11-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

On Wed, 24 May 2017, Laurent Dufour wrote:

>A new configuration variable is introduced to activate the use of
>range lock instead of semaphore to protect per process memory layout.
>
>This range lock is replacing the use of a semaphore for mmap_sem.
>
>Currently only available for X86_64 and PPC64 architectures.
>
>By default this option is turned off and requires the EXPERT mode
>since it is not yet complete.

Just fyi I find this option quite useful for dev and debugging purposes,
however it should not exist once any of this is seriously considered
for merging. The reason being is that fundamentally such internals
should not be exposed to configuration options. We either get it right
for everybody, or we don't.

I'm currently running lots of tests to see the overhead in real workloads
on different boxes. While I hope that my artificial testing somewhat
resembles some patterns, this will be the real deal.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
