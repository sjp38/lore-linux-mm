Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 980F8280255
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 19:53:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so192713260pfv.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 16:53:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id ud5si4372759pac.137.2016.09.22.16.53.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 16:53:02 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<20160922225608.GA3898@kernel.org>
	<045D8A5597B93E4EBEDDCBF1FC15F50935C1AD83@fmsmsx104.amr.corp.intel.com>
Date: Thu, 22 Sep 2016 16:53:02 -0700
In-Reply-To: <045D8A5597B93E4EBEDDCBF1FC15F50935C1AD83@fmsmsx104.amr.corp.intel.com>
	(Tim C. Chen's message of "Thu, 22 Sep 2016 23:49:00 +0000")
Message-ID: <87y42jo5k1.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>
Cc: Shaohua Li <shli@kernel.org>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

"Chen, Tim C" <tim.c.chen@intel.com> writes:

>>
>>So this is impossible without THP swapin. While 2M swapout makes a lot of
>>sense, I doubt 2M swapin is really useful. What kind of application is 'optimized'
>>to do sequential memory access?

Anything that touches regions larger than 4K and we want to do the
kernel do minimal work to manage the swapping.

>
> We waste a lot of cpu cycles to re-compact 4K pages back to a large page
> under THP.  Swapping it back in as a single large page can avoid
> fragmentation and this overhead.

Also splitting something just to merge it again is wasteful.

A lot of big improvements in the block and VM and network layers
over the years came from avoiding that kind of wasteful work.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
