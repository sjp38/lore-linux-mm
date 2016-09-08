Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6BA6B0253
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 13:22:02 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vp2so113457008pab.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 10:22:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f8si47619596pfd.211.2016.09.08.10.22.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 10:22:01 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 05/10] mm, THP, swap: Add get_huge_swap_page()
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-6-git-send-email-ying.huang@intel.com>
	<20160908111353.GD17331@node>
Date: Thu, 08 Sep 2016 10:22:01 -0700
In-Reply-To: <20160908111353.GD17331@node> (Kirill A. Shutemov's message of
	"Thu, 8 Sep 2016 14:13:53 +0300")
Message-ID: <87d1ketih2.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Wed, Sep 07, 2016 at 09:46:04AM -0700, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> A variation of get_swap_page(), get_huge_swap_page(), is added to
>> allocate a swap cluster (512 swap slots) based on the swap cluster
>> allocation function.  A fair simple algorithm is used, that is, only the
>> first swap device in priority list will be tried to allocate the swap
>> cluster.  The function will fail if the trying is not successful, and
>> the caller will fallback to allocate a single swap slot instead.  This
>> works good enough for normal cases.
>
> For normal cases, yes. But the limitation is not obvious for users and
> performance difference after small change in configuration could be
> puzzling.

If the difference of the number of the free swap clusters among
multiple swap devices is significant, it is possible that some THP are
split earlier than necessary because we fail to allocate the swap
clusters for them.  For example, this could be caused by big size
difference among multiple swap devices.

> At least this must be documented somewhere.

I can add the above description in the patch description.  Any other
places do you suggest?

Best Regards,
Huang, Ying

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
