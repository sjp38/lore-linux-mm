Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 69D526B0069
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 16:37:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g202so145289142pfb.3
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 13:37:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e73si13152786pfj.239.2016.09.02.13.37.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Sep 2016 13:37:29 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v2 01/10] swap: Change SWAPFILE_CLUSTER to 512
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
	<1472743023-4116-2-git-send-email-ying.huang@intel.com>
	<20160901142246.631fe47a558bb7522f73c034@linux-foundation.org>
	<87h99zdxwm.fsf@yhuang-mobile.sh.intel.com>
	<20160902133016.0a150c880174fa97f161912f@linux-foundation.org>
Date: Fri, 02 Sep 2016 13:37:29 -0700
In-Reply-To: <20160902133016.0a150c880174fa97f161912f@linux-foundation.org>
	(Andrew Morton's message of "Fri, 2 Sep 2016 13:30:16 -0700")
Message-ID: <87a8fqca2e.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 01 Sep 2016 16:04:57 -0700 "Huang\, Ying" <ying.huang@intel.com> wrote:
>
>> >>  }
>> >>  
>> >> -#define SWAPFILE_CLUSTER	256
>> >> +#define SWAPFILE_CLUSTER	512
>> >>  #define LATENCY_LIMIT		256
>> >>  
>> >
>> > What happens to architectures which have different HPAGE_SIZE and/or
>> > PAGE_SIZE?
>> 
>> For the architecture with HPAGE_SIZE / PAGE_SIZE == 512 (for example
>> x86_64), the huge page swap optimizing will be turned on.  For other
>> architectures, it will be turned off as before.
>> 
>> This mostly because I don't know whether it is a good idea to turn on
>> THP swap optimizing for the architectures other than x86_64.  For
>> example, it appears that the huge page size is 8M (1<<23) on SPARC.  But
>> I don't know whether 8M is too big for a swap cluster.  And it appears
>> that the huge page size could be as large as 512M on MIPS.
>
> This doesn't sounds very organized.  If some architecture with some
> config happens to have HPAGE_SIZE / PAGE_SIZE == 512 then the feature
> will be turned on; otherwise it will be turned off.  Nobody will even
> notice that it happened.
>
> Would it not be better to do
>
> #ifdef CONFIG_SOMETHING
> #define SWAPFILE_CLUSTER (HPAGE_SIZE / PAGE_SIZE)
> #else
> #define SWAPFILE_CLUSTER 256
> #endif
>
> and, by using CONFIG_SOMETHING in the other appropriate places, enable
> the feature in the usual fashion?

Yes.  That is better.  I will change it in the next version.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
