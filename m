Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1726B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 20:46:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 79so26776734pgf.2
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 17:46:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l3si441269pln.127.2017.03.29.17.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 17:46:00 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v7 1/9] mm, swap: Make swap cluster size same of THP size on x86_64
References: <20170328053209.25876-1-ying.huang@intel.com>
	<20170328053209.25876-2-ying.huang@intel.com>
	<20170329165522.GA31821@cmpxchg.org>
Date: Thu, 30 Mar 2017 08:45:56 +0800
In-Reply-To: <20170329165522.GA31821@cmpxchg.org> (Johannes Weiner's message
	of "Wed, 29 Mar 2017 12:55:22 -0400")
Message-ID: <87o9wjtwvv.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Tue, Mar 28, 2017 at 01:32:01PM +0800, Huang, Ying wrote:
>> @@ -499,6 +499,19 @@ config FRONTSWAP
>>  
>>  	  If unsure, say Y to enable frontswap.
>>  
>> +config ARCH_USES_THP_SWAP_CLUSTER
>> +	bool
>> +	default n
>
> This is fine.
>
>> +config THP_SWAP_CLUSTER
>> +	bool
>> +	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
>> +	default y
>> +	help
>> +	  Use one swap cluster to hold the contents of the THP
>> +	  (Transparent Huge Page) swapped out.  The size of the swap
>> +	  cluster will be same as that of THP.
>
> But this is a super weird thing to ask the user. How would they know
> what to say, if we don't know? I don't think this should be a config
> knob at all. Merge the two config items into a simple

The user will not see this, because there is no string after "bool" to
let user to select it.  The help here is for document only, so that
architecture developers could know what this is for.

> config THP_SWAP_CLUSTER
>      bool
>      default n
>
> and let the archs with reasonable THP sizes select it.

This will have same effect as the original solution except the document
is removed.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
